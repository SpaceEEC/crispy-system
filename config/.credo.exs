%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["apps/"],
        excluded: []
      },
      requires: [],
      checks: [
        # Consistency
        {Credo.Check.Consistency.ExceptionNames},
        {Credo.Check.Consistency.ParameterPatternMatching},
        # Design
        {Credo.Check.Design.AliasUsage},
        {Credo.Check.Design.DuplicatedCode},
        {Credo.Check.Design.TagTODO, exit_status: 0},
        # Readability
        {Credo.Check.Readability.FunctionNames},
        {Credo.Check.Readability.ModuleAttributeNames},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Readability.ModuleNames},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs, false},
        {Credo.Check.Readability.PredicateFunctionNames},
        {Credo.Check.Readability.VariableNames},
        # Refactor
        {Credo.Check.Refactor.CondStatements},
        {Credo.Check.Refactor.FunctionArity},
        {Credo.Check.Refactor.MatchInCondition},
        {Credo.Check.Refactor.NegatedConditionsInUnless},
        {Credo.Check.Refactor.NegatedConditionsWithElse},
        {Credo.Check.Refactor.Nesting},
        {Credo.Check.Refactor.UnlessWithElse},
        # Warning
        {Credo.Check.Warning.IExPry},
        {Credo.Check.Warning.IoInspect},
        {Credo.Check.Warning.OperationOnSameValues},
        {Credo.Check.Warning.BoolOperationOnSameValues},
        {Credo.Check.Warning.UnusedEnumOperation},
        {Credo.Check.Warning.UnusedKeywordOperation},
        {Credo.Check.Warning.UnusedListOperation},
        {Credo.Check.Warning.UnusedStringOperation},
        {Credo.Check.Warning.UnusedTupleOperation},
        {Credo.Check.Warning.OperationWithConstantResult},
        # Experimental
        {Credo.Check.Refactor.ABCSize},
        {Credo.Check.Refactor.AppendSingleItem},
        {Credo.Check.Warning.MapGetUnsafePass},
        {Credo.Check.Consistency.MultiAliasImportRequireUse}
      ]
    }
  ]
}
