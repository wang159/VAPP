classdef IrNodeAssignment < IrNodeNumerical
% IRNODEASSIGNMENT represents a Verilog-A assignment
%
% See also IRNODENUMERICAL

%==============================================================================
% This file is part of VAPP, the Berkeley Verilog-A Parser and Processor.   
% Author: A. Gokcen Mahmutoglu                                
% Last modified: Thu Aug 25, 2016  10:49AM
%==============================================================================
    properties (Access = private)
        accessIdx = 0;
    end

    methods

        function  obj = IrNodeAssignment(lhsNode, rhsNode)
            obj = obj@IrNodeNumerical();
            obj.additive = 1;
            if nargin > 0
                obj.addChild(lhsNode);
                obj.addChild(rhsNode);
            end
        end

        function aIdx = getAccessIdx(thisNode)
        % GETACCESSIDX
            aIdx = thisNode.accessIdx;
        end

        function setAccessIdx(thisNode, aIdx)
        % SETACCESSIDX
            thisNode.accessIdx = aIdx;
        end

        function outStr = sprintNumerical(thisNode, ~)
            lhsNode = thisNode.getLhsNode();
            rhsNode = thisNode.getRhsNode();
            lhsStr = lhsNode.sprintAll();
            rhsStr = rhsNode.sprintAll();

            if isempty(rhsStr) == true
                rhsStr = '0';
            end
            outStr = sprintf('%s = %s;\n', lhsStr, rhsStr);
        end

        function addChild(thisNode, childNode)
        % ADDCHILD
            if thisNode.nChild == 2
                VAPP_error('vapp-error', ['This assignment already has 2 children. The number',...
                       ' of children in an assignment cannot be more than 2!']);
            else
                addChild@IrNode(thisNode, childNode);
            end
        end

        function lhsNode = getLhsNode(thisNode)
            lhsNode = thisNode.getChild(1);
        end

        function rhsNode = getRhsNode(thisNode)
            rhsNode = thisNode.getChild(2);
        end

    % end methods
    end

    methods (Access = protected)

        function [headNode, generateSub] = generateDerivative(thisNode, derObj)
            generateSub = true;
            headNode = IrNodeAssignment();
        end

    end

% end classdef
end
