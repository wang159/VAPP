classdef IrNodeOutput < IrNodeNumerical
% IRNODEIMPLICITOUTPUT represents fi/qi/fe/qe output vector entries in ModSpec
% This class is an odd one. Ideally its functionality should be distributed
% into separate classes such as IrNodeImplicitOutput, IrNodeExplicitOutput,
% IrNodeKclKvlOutput etc. However, all fi/qi/fe/qe related functionality is
% collected here in this single class in order to prevent clutter.
%
% Because of the situation mentioned above, IrNodeOutput has some non-intuitive
% behaivor. First of all, its properties are somehow unnatural.
% outPfObj: This is the potential/flow object that gives rise to this output
%           equation. It can either be an explicit output or an internal IO.
%           This is where we get the information about this output object being
%           fe/qe or fi/qi and which index (outIdx) it has in this vector.
%
% lhsPfObj: This is the pfObj on the lhs of the equation. If this property is
%           empty, we assume that it is the same as the outPfObj. This is the
%           case for explicit outputs. For internal unknowns, it is either
%           equal to outPfObj or to its conjugate (i.e., if
%           outPfObj is a potential lhsPfObj is a flow and vice versa).
%           If outPfObj == lhsPfObj, that means we have a 

%==============================================================================
% This file is part of VAPP, the Berkeley Verilog-A Parser and Processor.   
% Author: A. Gokcen Mahmutoglu                                
% Last modified: Thu Aug 25, 2016  10:49AM
%==============================================================================
    properties (Access = private)
        outPfObj = MsPotential.empty;
        outIdx = 0;
        implicit = false;
        impContrib = 0;
        rhsPfVec = MsPotential.empty;
        rhsSignVec = [];
    end

    methods

        function obj = IrNodeOutput(pfObj)
        % IRNODEOUTPUT
            if nargin > 0
                obj.outPfObj = pfObj;
            end
        end

        function setOutIdx(thisOutput, outIdx)
        % SETOUTIDX
            if thisOutput.outIdx ~= 0
                VAPP_error('vapp-error', ['Cannot set output index because this output object',...
                       ' has already another one!']);
            else
                thisOutput.outIdx = outIdx;
            end
        end

        function setRhsPfVec(thisOutput, pfVec)
        % SETRHSPFVEC
            thisOutput.rhsPfVec = pfVec;
        end

        function setRhsSignVec(thisOutput, signVec)
        % SETRHSSIGNVEC
            thisOutput.rhsSignVec = signVec;
        end

        function setImplicit(thisOutput, impContrib)
        % SETIMPLICITI
            thisOutput.implicit = true;
            thisOutput.impContrib = impContrib;
        end

        function contrib = getImplicitContrib(thisOutput)
        % GETIMPLICITCONTRIB
            contrib = thisOutput.impContrib;
        end

        function varLabel = getImplicitEqnVarLabel(thisOutput, fOrQ)
        % GETIMPLICITEQNVARNAME
            varLabel = thisOutput.impContrib.getImplicitEqnVarLabel(fOrQ);
        end

        function derivVarName = getImplicitDerivVarName(thisOutput, derivObj, fOrQ)
        % GETIMPLICITDERIVVARNAME
            derivVarName = thisOutput.impContrib.getImplicitEqnDerivVarLabel(derivObj, fOrQ);
        end

        function out = isImplicit(thisOutput)
        % ISIMPLICIT
            out = thisOutput.implicit;
        end

        function lhsNode = getLhsNode(thisOutput)
        % GETLHSNODE
            lhsNode = thisOutput.getChild(1);
        end

        function rhsPfVec = getRhsPfVec(thisOutput)
        % GETRHSPFVEC
            rhsPfVec = thisOutput.rhsPfVec;
        end

        function outStr = sprintRhs(thisOutput, fOrQ)
        % SPRINTRHS
            outStr = '';
            rhsPfVec = thisOutput.rhsPfVec;
            nRhsPf = numel(rhsPfVec);
            signVec = thisOutput.rhsSignVec;
            varSfx = thisOutput.VARSFX;

            if numel(signVec) ~= nRhsPf
                VAPP_error('vapp-error', 'Number of rhs nodes and number of signs do not match!');
            end

            if strcmp(fOrQ, 'f')
                labelFunc = @getFLabel;
            elseif strcmp(fOrQ, 'q')
                labelFunc = @getQLabel;
            end

            for i = 1:nRhsPf
                label = labelFunc(rhsPfVec(i));
                if isempty(label) == false
                    if signVec(i) == 1
                        signStr = '+';
                    else
                        signStr = '-';
                    end

                    outStr = [outStr, signStr, label, varSfx];
                end
            end
        end

        function fqSfx = getFQSfx(thisOutput)
        % GETFQSFX
            
            outPfObj = thisOutput.outPfObj;

            if isempty(outPfObj) == false
                if outPfObj.isExpOut() == true
                    fqSfx = 'e';
                %elseif outPfObj.isIntUnk() == true
                %    fqSfx = 'i';
                %elseif outPfObj.isOtherIo() == true
                %    fqSfx = 'i';
                else
                    fqSfx = 'i';
                end
            else
                fqSfx = 'i';
            end

        end

        function [outStr, printSub] = sprintNumerical(thisOutput, ~)
        % SPRINTFRONT
            outIdx = num2str(thisOutput.outIdx);
            printSub = false;
            varSfx = thisOutput.VARSFX;
            outPfObj = thisOutput.outPfObj;

            fqSfx = thisOutput.getFQSfx();
            fStr = ['f', fqSfx, varSfx, '(', outIdx, ')'];
            qStr = ['q', fqSfx, varSfx, '(', outIdx, ')'];

            if thisOutput.implicit == false

                outStr = ['// output for ', outPfObj.getLabel()];
                if outPfObj.isExpOut() == true
                    outStr = [outStr, ' (explicit out)\n'];
                elseif outPfObj.isIntUnk() == true
                    outStr = [outStr, ' (internal unknown)\n'];
                elseif outPfObj.isOtherIo() == true
                    outStr = [outStr, ' (other IO)\n'];
                end

                lhsNode = thisOutput.getLhsNode();
                % print f part
                lhsFStr = lhsNode.getFLabel();
                rhsFStr = thisOutput.sprintRhs('f');

                if isempty(rhsFStr) == true
                    rhsFStr = '0';
                end

                if isempty(lhsFStr) == false
                    lhsFStr = [lhsFStr, varSfx];
                    if lhsNode.isInverse() == false
                        rhsFStr = [rhsFStr, ' - ', lhsFStr];
                    else
                        rhsFStr = [rhsFStr, ' + ', lhsFStr];
                    end
                end

                fStr = [fStr, ' = ', rhsFStr, ';\n'];

                % print q part
                rhsQStr = thisOutput.sprintRhs('q');
                lhsQStr = lhsNode.getQLabel();

                if isempty(rhsQStr) == true
                    rhsQStr = '0';
                end

                if isempty(lhsQStr) == false
                    lhsQStr = [lhsQStr, varSfx];
                    if lhsNode.isInverse() == false
                        rhsQStr = [rhsQStr, ' - ', lhsQStr];
                    else
                        rhsQStr = [rhsQStr, ' + ', lhsQStr];
                    end
                end

                qStr = [qStr, ' = ', rhsQStr, ';\n'];
            else
                impEqnIdxStr = num2str(thisOutput.impContrib.getImpContribIdx());
                outStr = ['// Output for implicit equation (', impEqnIdxStr, ')\n'];
                fStr = [fStr, ' = ', thisOutput.getImplicitEqnVarLabel('f'), varSfx, ';\n'];
                qStr = [qStr, ' = ', thisOutput.getImplicitEqnVarLabel('q'), varSfx, ';\n'];
            end

            outStr = [outStr, fStr, qStr];
        end

    % end methods
    end

    methods (Access = protected)
        function [headNode, generateSub] = generateDerivative(thisOutput, derivObj)
        % GENERATEDERIVATIVE
            generateSub = false;
            eOrI = thisOutput.getFQSfx();
            outIdx = thisOutput.outIdx;
            headNode = IrNodeJacobian(eOrI, outIdx, derivObj);

            if thisOutput.implicit == false
                rhsPfVec = thisOutput.rhsPfVec;
                signVec = thisOutput.rhsSignVec;
                lhsNode = thisOutput.getLhsNode();

                rhsDerivVarNodeVecF = IrNodeVariable.empty;
                rhsDerivVarNodeVecQ = IrNodeVariable.empty;

                for pfObj = rhsPfVec
                    pfNode = IrNodePotentialFlow(pfObj);
                    rhsDerivVarNodeVecF = [rhsDerivVarNodeVecF, ...
                                    pfNode.generateDerivativeFQ(derivObj, 'f')];
                    rhsDerivVarNodeVecQ = [rhsDerivVarNodeVecQ, ...
                                    pfNode.generateDerivativeFQ(derivObj, 'q')];
                end

                % generate the derivative for lhs node
                if lhsNode.isNull() == false
                    rhsDerivVarNodeVecF = [rhsDerivVarNodeVecF, ...
                                    lhsNode.generateDerivativeFQ(derivObj, 'f')];
                    rhsDerivVarNodeVecQ = [rhsDerivVarNodeVecQ, ...
                                    lhsNode.generateDerivativeFQ(derivObj, 'q')];
                    % as opposed to printing the actual output, here we don't
                    % check if the lhsNode is inverse or not. The reason is:
                    % the derivative generation code will take care of inverse
                    % PFs on its own. For the relevant part see
                    % IrNodePotentialFlow.generateDerivativeFQ:
                    % >     if thisPF.inverse == false
                    % >         headNode = varNode;
                    % >     else
                    % >         headNode = IrNodeNumerical.getNegativeOfNode(varNode);
                    % >     end
                    signVec = [signVec, -1];
                end

                if isempty(rhsDerivVarNodeVecF) == false
                    rhsNodeF = IrNodeNumerical.getLinearCombination(rhsDerivVarNodeVecF, signVec);
                else
                    rhsNodeF = IrNodeNumericalNull();
                end

                if isempty(rhsDerivVarNodeVecQ) == false
                    rhsNodeQ = IrNodeNumerical.getLinearCombination(rhsDerivVarNodeVecQ, signVec);
                else
                    rhsNodeF = IrNodeNumericalNull();
                end

            else
                varSfx = thisOutput.VARSFX;
                impContrib = thisOutput.impContrib;
                derivVarLabelF = impContrib.getImplicitEqnDerivVarLabel(derivObj, 'f');
                derivVarLabelQ = impContrib.getImplicitEqnDerivVarLabel(derivObj, 'q');
                rhsNodeF = IrNodeVariable([derivVarLabelF, varSfx]);
                rhsNodeQ = IrNodeVariable([derivVarLabelQ, varSfx]);
            end

            headNode.addChild(rhsNodeF);
            headNode.addChild(rhsNodeQ);
        end
    end

% end classdef
end
