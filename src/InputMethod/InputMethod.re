open Belt;

module Impl = (Editor: Sig.Editor) => {
  open Command.InputMethodAction;
  module Buffer2 = Buffer2.Impl(Editor);

  module Instance = {
    type t = {
      mutable range: (int, int),
      decoration: array(Editor.Decoration.t),
      mutable buffer: Buffer2.t,
    };

    let make = (editor, offset) => {
      let point = Editor.pointAtOffset(editor, offset);
      {
        range: (offset, offset),
        decoration:
          Editor.Decoration.underlineText(
            editor,
            Editor.Range.make(point, point),
          ),
        buffer: Buffer2.make(),
      };
    };

    let withIn = (instance, offset) => {
      let (start, end_) = instance.range;
      start <= offset && offset <= end_;
    };

    let destroy = instance => {
      Js.log("KILLED");
      instance.decoration->Array.forEach(Editor.Decoration.destroy);
    };
  };

  type t = {
    onAction: Event.t(Command.InputMethodAction.t),
    mutable instances: array(Instance.t),
    mutable activated: bool,
  };

  let insertBackslash = editor => {
    Editor.getCursorPositions(editor)
    ->Array.forEach(point => {
        Editor.insertText(editor, point, "\\")->ignore
      });
  };

  let activate = (self, editor, offsets: array(int)) => {
    // instantiate from an array of offsets
    self.instances =
      Js.Array.sortInPlaceWith(compare, offsets)
      ->Array.map(Instance.make(editor));

    // handles of listeners
    let editorChangeHandle = ref(None);
    let cursorChangeHandle = ref(None);

    // destroy the handles if all Instances are destroyed
    let checkIfEveryoneIsStillAlive = () =>
      if (Array.length(self.instances) == 0) {
        Js.log("ALL DEAD");
        self.onAction.emit(Deactivate);
        (editorChangeHandle^)->Option.forEach(Editor.Disposable.dispose);
        (cursorChangeHandle^)->Option.forEach(Editor.Disposable.dispose);
      };

    // listeners
    let editorChangelistener = (changes: array(Editor.changeEvent)) => {
      // sort the changes base on their offsets, from small to big
      let changes =
        Js.Array.sortInPlaceWith(
          (x: Editor.changeEvent, y: Editor.changeEvent) =>
            compare(x.offset, y.offset),
          changes,
        );

      let rec scanAndUpdate:
        (int, (list(Editor.changeEvent), list(Instance.t))) =>
        list(Instance.t) =
        accum =>
          fun
          | ([change, ...cs], [instance, ...is]) => {
              let (start, end_) = instance.range;
              let delta =
                String.length(change.insertText) - change.replaceLength;
              Js.log("delta " ++ string_of_int(delta));

              // Js.log((
              //   delta,
              //   "("
              //   ++ string_of_int(fst(instance.range))
              //   ++ ", "
              //   ++ string_of_int(snd(instance.range))
              //   ++ ")",
              //   change.offset,
              // ));
              // `change.offset` is the untouched offset before any modifications happened
              // so it's okay to compare it with the also untouched `instance.range`
              if (Instance.withIn(instance, change.offset)) {
                // `change` appears inside the `instance`
                let next =
                  Buffer2.update(instance.range, instance.buffer, change);
                switch (next) {
                | Noop =>
                  instance.range = (accum + start, accum + end_ + delta);
                  [instance, ...scanAndUpdate(accum + delta, (cs, is))];
                | Update(buffer) =>
                  instance.buffer = buffer;
                  instance.range = (accum + start, accum + end_ + delta);
                  [instance, ...scanAndUpdate(accum + delta, (cs, is))];
                | UpdateAndReplaceText(buffer, text) =>
                  instance.buffer = buffer;
                  // Js.log("DELTA' " ++ string_of_int(delta'));
                  // update the buffer
                  let originalRange =
                    Editor.Range.make(
                      Editor.pointAtOffset(editor, accum + start),
                      Editor.pointAtOffset(editor, accum + end_ + delta),
                    );
                  Editor.setText(editor, originalRange, text)->ignore;

                  // Js.log(
                  //   "("
                  //   ++ string_of_int(accum + start)
                  //   ++ ", "
                  //   ++ string_of_int(accum + end_ + delta)
                  //   ++ ") => ("
                  //   ++ string_of_int(accum + start)
                  //   ++ ", "
                  //   ++ string_of_int(accum + end_ + delta + delta')
                  //   ++ ")",
                  // );

                  instance.range = (accum + start, accum + end_ + delta);
                  [instance, ...scanAndUpdate(accum + delta, (cs, is))];
                };
              } else if (change.offset < fst(instance.range)) {
                // `change` appears before the `instance`
                scanAndUpdate(
                  accum + delta, // update only `accum`
                  (cs, [instance, ...is]),
                );
              } else {
                // `change` appears after the `instance`
                instance.range = (accum + start, accum + end_);
                [instance, ...scanAndUpdate(accum, ([change, ...cs], is))];
              };
            }
          | ([], [instance, ...is]) => [instance, ...is]
          | (_, []) => [];

      self.instances =
        scanAndUpdate(
          0,
          (List.fromArray(changes), List.fromArray(self.instances)),
        )
        ->List.toArray;
    };

    // kill the Instances that are not are not pointed by cursors
    let cursorChangelistener = (points: array(Editor.Point.t)) => {
      let offsets = points->Array.map(Editor.offsetAtPoint(editor));
      Js.log(
        "CURSORS: " ++ offsets->Array.map(string_of_int)->Util.Pretty.array,
      );
      self.instances =
        self.instances
        ->Array.keep((instance: Instance.t) => {
            // if any cursor falls into the range of the instance, the instance survives
            let survived =
              offsets->Belt.Array.some(Instance.withIn(instance));
            // if not, the instance gets destroyed
            Js.log(
              "CURSORS Instance ("
              ++ string_of_int(fst(instance.range))
              ++ ", "
              ++ string_of_int(snd(instance.range))
              ++ ")",
            );
            if (!survived) {
              Instance.destroy(instance);
            };
            // survived;
            true;
          });

      checkIfEveryoneIsStillAlive();
    };
    // initiate listeners
    cursorChangeHandle :=
      Some(Editor.onChangeCursorPosition(cursorChangelistener));
    editorChangeHandle :=
      Some(
        Editor.onChange(changes => {
          checkIfEveryoneIsStillAlive();
          editorChangelistener(changes);
        }),
      );
  };

  let make = () => {
    {onAction: Event.make(), instances: [||], activated: false};
  };
};