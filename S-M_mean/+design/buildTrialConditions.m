function condList = buildTrialConditions(stimCombos, ratioAssignments, diffLevels, repeats)
%BUILDTRIALCONDITIONS Generate factorial trial definitions.
%   condList = BUILDTRIALCONDITIONS(stimCombos, ratioAssignments,
%   diffLevels, repeats) returns a struct array enumerating all
%   combinations of the supplied factors, repeated `repeats` times.

condIdx = 1;
for rep = 1:repeats
    for ratioIdx = 1:numel(ratioAssignments)
        for diffIdx = 1:numel(diffLevels)
            for comboIdx = 1:numel(stimCombos)
                condList(condIdx).comboLabel = stimCombos{comboIdx}; %#ok<AGROW>
                condList(condIdx).ratioIdx   = ratioIdx;
                condList(condIdx).diffLevel  = diffLevels(diffIdx);
                condIdx = condIdx + 1;
            end
        end
    end
end
end