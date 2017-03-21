classdef IrNodeModel < IrNode
% IRNODEMODEL

%==============================================================================
% This file is part of VAPP, the Berkeley Verilog-A Parser and Processor.
% Author: A. Gokcen Mahmutoglu
% Last modified: Thu Aug 25, 2016  10:49AM
%==============================================================================
    properties (Constant)
        VALIDPRINTMODES = {'iolist', 'ionumber', 'ioinit'};
    end
    properties
        modelObj = MsModel.empty;
        printMode = '';
    end

    methods

        function obj = IrNodeModel(modelObj)
            obj = obj@IrNode();
            if nargin > 0
                obj.modelObj = modelObj;
            end
        end

        function out = acceptVisitor(thisModel, visitor, varargin)
        % ACCEPTVISITOR
            thisModel.computeCoreModel();
            out = acceptVisitor@IrNode(thisModel, visitor, varargin{:});
        end

        function [outStr, printSub] = sprintFront(thisModel)
            printSub = false;
            model = thisModel.modelObj;
            outStr = '';
            printMode = thisModel.printMode;

            switch printMode
                case 'iolist'
                    outStr = [outStr, sprintf('eonames = {%s};\n',...
                                    cell2str_vapp(model.getExpOutList(),  ''''))];
                    outStr = [outStr, sprintf('iunames = {%s};\n',...
                                    cell2str_vapp(model.getIntUnkList(), ''''))];

                    outStr = [outStr, sprintf('ienames = {%s};\n',...
                                    cell2str_vapp(model.getIntEqnNameList(), ''''))];
                case 'ionumber'
                    outStr = sprintf(['nFeQe = %d;\n', 'nFiQi = %d;\n',...
                                     'nOtherIo = %d;\n', 'nIntUnk = %d;\n'],...
                                     model.getNFeQe(), model.getNFiQi(),...
                                     model.getNOtherIo(), model.getNIntUnk());
                case 'ioinit'
                    outStr = model.sprintInitIos();
                otherwise
                    thisModel.computeCoreModel();
            end
        end

        function computeCoreModel(thisModel)
        % COMPUTECOREMODEL
            thisModel.modelObj.collapseBranches();
            thisModel.modelObj.computeCoreModel();
            thisModel.modelObj.uncollapseBranches();
        end

        function setPrintMode(thisModel, printMode)
        % SETPRINTMODE
            if any(strcmp(printMode, IrNodeModel.VALIDPRINTMODES)) == true
                thisModel.printMode = printMode;
            else
                VAPP_error('vapp-error', sprintf('Error in IrNodeModel: %s is not a valid print mode!', ...
                                                                    printMode));
            end
        end

        function outputTree = getOutputTree(thisModel)
        % GETOUTPUTTREE
            outputTree = thisModel.modelObj.getOutputTree();
        end

        function ioDefTree = getIoDefTree(thisModel)
        % GETOUTPUTTREE
            ioDefTree = thisModel.modelObj.getIoDefTree();
        end
    % end methods
    end
    
% end classdef
end
