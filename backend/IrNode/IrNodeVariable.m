classdef IrNodeVariable < IrNodeDifferentiable
% IRNODEVARIABLE represents a variable in Verilog-A
% This class is a container for an MsVariable object.
% See also MSVARIABLE

%==============================================================================
% This file is part of VAPP, the Berkeley Verilog-A Parser and Processor.   
% Author: A. Gokcen Mahmutoglu                                
% Last modified: Thu Aug 25, 2016  10:49AM
%==============================================================================
    properties (Access = private)
        varObj = MsVariable.empty;
        label = '';
    end

    methods
        function obj = IrNodeVariable(varNameOrObj)
            obj = obj@IrNodeDifferentiable();
            if isa(varNameOrObj, 'MsVariable') == true
                obj.varObj = varNameOrObj;
            elseif ischar(varNameOrObj) == true 
                obj.label = varNameOrObj;
            else
                VAPP_error('vapp-error', ['A variable node can only be created either by a',...
                       ' variable label or a MsVariable object']);
            end

            obj.additive = 1;
            obj.multiplicative = 1;
        end

        function setConnectedToModule(thisVar)
        % SETCONNECTEDTOMODULE
            if isempty(thisVar.varObj) == true
                % notify module about this new var and get a MsVariable object
                % in return
                thisVar.addVarToModule();
            end

            setConnectedToModule@IrNode(thisVar);
        end

        function addVarToModule(thisVar)
        % ADDVARTOMODULE
            thisVar.varObj = addVarToModule@IrNode(thisVar.parent, thisVar.label);
        end

        function varName = getName(thisVariable)
            varName = thisVariable.varObj.getName();
        end

        function varObj = getVarObj(thisVariable)
            varObj = thisVariable.varObj;
        end

        function outStr = sprintNumerical(thisNode, ~)
            outStr = thisNode.getName();
        end
        
        function depVarVec = getDependVarVec(thisNode)
            depVarVec = thisNode.varObj.getDependVarVec();
        end

        function depIoVec = getDependIoVec(thisNode)
            depIoVec = thisNode.varObj.getDependIoVec();
        end

        function headNode = resetDerivativeToZero(thisVarNode, derivObj)

            % this function is used to generate equations like
            % d_varname_dervarname__ = 0;
            % These are required in some cases. For an explanation see the
            % comments in the IrVisitorGenerateDerivative.visitAssignment()
            % method
            varObj = thisVarNode.varObj;
            varSfx = thisVarNode.VARSFX;

            if derivObj == varObj
                VAPP_error('vapp-error', sprintf('Derivative of %s is being set to zero with respect to itself!', varObj.getName()), derivObj);
            elseif varObj.isDependentOnDerivObj(derivObj)
                derVarName = [varObj.getDerivLabel(derivObj), varSfx];
                topModule = thisVarNode.getModule();
                derVarObj = topModule.addVar(derVarName, ...
                                             IrNodeNumerical.getConstantNode(0));
                derVarObj.setDerivative();
                derVarNode = IrNodeVariable(derVarObj);

                headNode = IrNodeAssignment();
                headNode.addChild(derVarNode);
                zeroNode = IrNodeNumerical.getConstantNode(0);
                headNode.addChild(zeroNode);
            else
                headNode = IrNodeNumericalNull();
            end

        end

        function out = isDependentOnDerivObj(thisVarNode, derivObj)
            out = thisVarNode.varObj.isDependentOnDerivObj(derivObj);
        end

        function module = getModule(thisNode)
        % GETMODULE
            module = thisNode.varObj.getModule();
        end

    % end methods
    end

    methods (Access = protected)

        function [headNode, generateSub] = generateDerivative(thisVarNode, derivObj)
            generateSub = false; % should have no children anyway
            varObj = thisVarNode.varObj;
            varSfx = thisVarNode.VARSFX;

            if derivObj == varObj
                headNode = IrNodeNumerical.getConstantNode(1);
            elseif varObj.isDependentOnDerivObj(derivObj)
                derVarName = varObj.getDerivLabel(derivObj);
                derVarName = [derVarName, varSfx];
                topModule = thisVarNode.getModule();
                derVarObj = topModule.addVar(derVarName, ...
                                             IrNodeNumerical.getConstantNode(0));
                derVarObj.setDerivative();
                headNode = IrNodeVariable(derVarObj);
            else
                headNode = IrNodeNumericalNull();
            end

        end

    end

end
