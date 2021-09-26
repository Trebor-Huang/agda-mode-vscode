open Belt

// https://github.com/agda/agda/blob/master/src/full/Agda/Interaction/Highlighting/Precise.hs
module Aspect = {
  // a mix of Aspect, OtherAspect and NameKind
  type t =
    | // the Aspect part
    Comment
    | Keyword
    | String
    | Number
    | Symbol
    | PrimitiveType
    | Pragma
    | Background
    | Markup
    | // the OtherAspect part
    Error
    | DottedPattern
    | UnsolvedMeta
    | UnsolvedConstraint
    | TerminationProblem
    | PositivityProblem
    | Deadcode
    | CoverageProblem
    | IncompletePattern
    | TypeChecks
    | CatchallClause
    | ConfluenceProblem
    | // the NameKind part
    Bound
    | Generalizable
    | ConstructorInductive
    | ConstructorCoInductive
    | Datatype
    | Field
    | Function
    | Module
    | Postulate
    | Primitive
    | Record
    | Argument
    | Macro
    | // when the second field of Aspect.Name is True
    Operator

  let toString = x =>
    switch x {
    // the Aspect part
    | Comment => "Comment"
    | Keyword => "Keyword"
    | String => "String"
    | Number => "Number"
    | Symbol => "Symbol"
    | PrimitiveType => "PrimitiveType"
    | Pragma => "Pragma"
    | Background => "Background"
    | Markup => "Markup"
    // the OtherAspect part
    | Error => "Error"
    | DottedPattern => "DottedPattern"
    | UnsolvedMeta => "UnsolvedMeta"
    | UnsolvedConstraint => "UnsolvedConstraint"
    | TerminationProblem => "TerminationProblem"
    | PositivityProblem => "PositivityProblem"
    | Deadcode => "Deadcode"
    | CoverageProblem => "CoverageProblem"
    | IncompletePattern => "IncompletePattern"
    | TypeChecks => "TypeChecks"
    | CatchallClause => "CatchallClause"
    | ConfluenceProblem => "ConfluenceProblem"
    // the NameKind part
    | Bound => "Bound"
    | Generalizable => "Generalizable"
    | ConstructorInductive => "ConstructorInductive"
    | ConstructorCoInductive => "ConstructorCoInductive"
    | Datatype => "Datatype"
    | Field => "Field"
    | Function => "Function"
    | Module => "Module"
    | Postulate => "Postulate"
    | Primitive => "Primitive"
    | Record => "Record"
    | Argument => "Argument"
    | Macro => "Macro"
    // when the second field of Aspect.Name is True
    | Operator => "Operator"
    }

  let parse = x =>
    switch x {
    | "comment" => Comment
    | "keyword" => Keyword
    | "string" => String
    | "number" => Number
    | "symbol" => Symbol
    | "primitivetype" => PrimitiveType
    | "pragma" => Pragma
    | "background" => Background
    | "markup" => Markup

    | "error" => Error
    | "dottedpattern" => DottedPattern
    | "unsolvedmeta" => UnsolvedMeta
    | "unsolvedconstraint" => UnsolvedConstraint
    | "terminationproblem" => TerminationProblem
    | "positivityproblem" => PositivityProblem
    | "deadcode" => Deadcode
    | "coverageproblem" => CoverageProblem
    | "incompletepattern" => IncompletePattern
    | "typechecks" => TypeChecks
    | "catchallclause" => CatchallClause
    | "confluenceproblem" => ConfluenceProblem

    | "bound" => Bound
    | "generalizable" => Generalizable
    | "inductiveconstructor" => ConstructorInductive
    | "coinductiveconstructor" => ConstructorCoInductive
    | "datatype" => Datatype
    | "field" => Field
    | "function" => Function
    | "module" => Module
    | "postulate" => Postulate
    | "primitive" => Primitive
    | "record" => Record
    | "argument" => Argument
    | "macro" => Macro

    | "operator" => Operator
    | _ => Operator
    }
}

// information of Tokens from Agda
module Token = {
  open Parser.SExpression
  type filepath = string
  type t = {
    start: int, // agda offset
    end_: int, // agda offset
    aspects: array<Aspect.t>, // a list of names of aspects
    isTokenBased: bool,
    note: option<string>,
    source: option<(filepath, int)>, // The defining module and the position in that module
  }
  let toString = self =>
    "Annotation " ++
    (string_of_int(self.start) ++
    (" " ++
    (string_of_int(self.end_) ++
    (" " ++
    (Util.Pretty.list(List.fromArray(self.aspects)) ++
    switch self.source {
    | None => ""
    | Some((s, i)) => s ++ (" " ++ string_of_int(i))
    })))))
  let parse: Parser.SExpression.t => option<t> = x =>
    switch x {
    | A(_) => None
    | L(xs) =>
      switch xs {
      | [A(start'), A(end_'), aspects, _, _, L([A(filepath), _, A(index')])] =>
        int_of_string_opt(start')->Option.flatMap(start =>
          int_of_string_opt(end_')->Option.flatMap(end_ =>
            int_of_string_opt(index')->Option.map(index => {
              start: start - 1,
              end_: end_ - 1,
              aspects: flatten(aspects)->Array.map(Aspect.parse),
              isTokenBased: false, // NOTE: fix this
              note: None, // NOTE: fix this
              source: Some((filepath, index)),
            })
          )
        )

      | [A(start'), A(end_'), aspects] =>
        int_of_string_opt(start')->Option.flatMap(start =>
          int_of_string_opt(end_')->Option.map(end_ => {
            start: start - 1,
            end_: end_ - 1,
            aspects: flatten(aspects)->Array.map(Aspect.parse),
            isTokenBased: false, // NOTE: fix this
            note: None, // NOTE: fix this
            source: None,
          })
        )
      | [A(start'), A(end_'), aspects, _] =>
        int_of_string_opt(start')->Option.flatMap(start =>
          int_of_string_opt(end_')->Option.map(end_ => {
            start: start - 1,
            end_: end_ - 1,
            aspects: flatten(aspects)->Array.map(Aspect.parse),
            isTokenBased: false, // NOTE: fix this
            note: None, // NOTE: fix this
            source: None,
          })
        )
      | _ => None
      }
    }
  let parseDirectHighlightings: array<Parser.SExpression.t> => array<t> = tokens =>
    tokens->Js.Array.sliceFrom(2, _)->Array.map(parse)->Array.keepMap(x => x)

  let decode: Json.Decode.decoder<t> = {
    open Json.Decode
    Util.Decode.tuple6(
      int,
      int,
      array(string),
      bool,
      optional(string),
      optional(pair(string, int)),
    ) |> map(((start, end_, aspects, isTokenBased, note, source)) => {
      start: start - 1,
      end_: end_ - 1,
      aspects: aspects->Array.map(Aspect.parse),
      isTokenBased: isTokenBased,
      note: note,
      source: source,
    })
  }
}

module type Module = {
  type t

  let make: unit => t

  let decodeHighlightingInfoDirect: Json.Decode.decoder<(bool, array<Token.t>)>
  let get: t => AVLTree.t<(Token.t, VSCode.Range.t)>

  let addEmacsFilePath: (t, string) => unit
  let addJSONFilePath: (t, string) => unit
  let readTempFiles: (t, VSCode.TextEditor.t) => Promise.promise<unit>
  let insert: (t, VSCode.TextEditor.t, array<Token.t>) => unit
  let clear: t => unit

  let lookupSrcLoc: (
    t,
    int,
  ) => option<Promise.t<array<(VSCode.Range.t, Token.filepath, VSCode.Position.t)>>>
}

module Module: Module = {
  module TempFile = {
    type t =
      | Emacs(string)
      | JSON(string)
    let toFilepath = format =>
      switch format {
      | Emacs(filepath) => filepath
      | JSON(filepath) => filepath
      }
  }

  type t = {
    // from addEmacsFilePath/addJSONFilePath
    mutable tempFiles: array<TempFile.t>,
    // Tokens indexed by the starting offset
    mutable tokens: AVLTree.t<(Token.t, VSCode.Range.t)>,
  }

  let make = () => {
    tempFiles: [],
    tokens: AVLTree.make(),
  }

  // decode Response from Agda or from temp files
  let decodeHighlightingInfoDirect: Json.Decode.decoder<(bool, array<Token.t>)> = {
    open Json.Decode
    pair(bool, array(Token.decode)) |> map(((keepHighlighting, xs)) => (keepHighlighting, xs))
  }

  // insert a bunch of Tokens
  // merge Aspects with the existing Token that occupies the same Range
  let insert = (self, editor, tokens: array<Token.t>) => {
    tokens->Array.forEach(info => {
      let existing = self.tokens->AVLTree.find(info.start)
      switch existing {
      | None =>
        let document = editor->VSCode.TextEditor.document
        let text = Editor.Text.getAll(document)
        let offsetConverter = Agda.OffsetConverter.make(text)
        let start = Editor.Position.fromOffset(
          document,
          Agda.OffsetConverter.convert(offsetConverter, info.start),
        )
        let end_ = Editor.Position.fromOffset(
          document,
          Agda.OffsetConverter.convert(offsetConverter, info.end_),
        )
        let range = VSCode.Range.make(start, end_)
        self.tokens->AVLTree.insert(info.start, (info, range))->ignore
      | Some((old, range)) =>
        // merge Aspects
        self.tokens->AVLTree.remove(info.start)->ignore
        // often the new aspects would look exactly like the old ones
        // don't duplicate them in that case
        let newAspects =
          old.aspects == info.aspects ? old.aspects : Array.concat(old.aspects, info.aspects)
        let new = {
          ...old,
          aspects: newAspects,
        }
        self.tokens->AVLTree.insert(info.start, (new, range))->ignore
      }
    })
  }

  let addEmacsFilePath = (self, filepath) =>
    Js.Array.push(TempFile.Emacs(filepath), self.tempFiles)->ignore
  let addJSONFilePath = (self, filepath) =>
    Js.Array.push(TempFile.JSON(filepath), self.tempFiles)->ignore

  // read temp files and add Tokens added from "addEmacsFilePath" or "addJSONFilePath"
  let readTempFiles = (self, editor) => {
    let readAndParseTempFile = format => {
      N.Util.promisify(N.Fs.readFile)(. TempFile.toFilepath(format))
      ->Promise.Js.fromBsPromise
      ->Promise.Js.toResult
      ->Promise.map(x =>
        switch x {
        | Ok(buffer) =>
          switch format {
          | Emacs(_) =>
            let tokens = switch Parser.SExpression.parse(Node.Buffer.toString(buffer))[0] {
            | Some(Ok(L(xs))) => xs
            | _ => []
            }
            // RemoveTokenBasedHighlighting
            let removeTokenBasedHighlighting = switch tokens[0] {
            | Some(A("remove")) => true
            | _ => false
            }
            let tokens = Js.Array.sliceFrom(1, tokens)->Array.keepMap(Token.parse)
            (removeTokenBasedHighlighting, tokens)
          | JSON(_) =>
            let raw = Node.Buffer.toString(buffer)
            switch Js.Json.parseExn(raw) {
            | exception _e => (false, [])
            | json => decodeHighlightingInfoDirect(json)
            }
          }
        | Error(_err) => (false, [])
        }
      )
    }

    // read and parse and concat them
    self.tempFiles
    ->Array.map(readAndParseTempFile)
    ->Promise.allArray
    ->Promise.map(xs => xs->Array.map(snd)->Array.concatMany)
    ->Promise.map(tokens => {
      insert(self, editor, tokens)
      self.tempFiles = []
    })
  }

  let clear = self => {
    // delete all unhandded temp files
    self.tempFiles->Array.forEach(format => {
      N.Fs.unlink(TempFile.toFilepath(format), _ => ())
    })
    self.tokens = AVLTree.make()
  }

  let get = self => self.tokens

  let lookupSrcLoc = (self, offset): option<
    Promise.t<array<(VSCode.Range.t, Token.filepath, VSCode.Position.t)>>,
  > => {
    self.tokens
    ->AVLTree.lowerBound(offset)
    ->Option.flatMap(((info, range)) =>
      info.source->Option.map(((filepath, offset)) => (range, filepath, offset))
    )
    ->Option.map(((range, filepath, offset)) => {
      VSCode.Workspace.openTextDocumentWithFileName(filepath)->Promise.map(document => {
        let text = Editor.Text.getAll(document)
        let offsetConverter = Agda.OffsetConverter.make(text)
        let offset = Agda.OffsetConverter.convert(offsetConverter, offset - 1)
        let position = Editor.Position.fromOffset(document, offset)
        [(range, filepath, position)]
      })
    })
  }
}

include Module