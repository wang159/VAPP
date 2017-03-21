function output = VAPP_error(errType, errMsg, errNode, errOpts)

%==============================================================================
% This file is part of VAPP, the Berkeley Verilog-A Parser and Processor.   
% Author: A. Gokcen Mahmutoglu
% Last modified: Wed Jun 29, 2016  11:28AM
%==============================================================================

% reset this presistent variable by calling VAPP_error('reset');
persistent valintLog;

stdout_header = [];

nodeinfo.type = errType;
nodeinfo.filename = '';
nodeinfo.lineno = [0 0];
nodeinfo.linepos = '';
nodeinfo.origin_content = '';

terminate_program = 0; % 1 = terminate with error

% obtain information from the node objection
if nargin > 2
    nodeinfo = get_nodeinfo(errNode, nodeinfo);
end

%% Do the following for specific errors

switch errType
    case 'reset'
        % reset the persistent error log
        valintLog = [];
        return
        
    case 'nothing'
        % does not do anything. just get log
        output = valintLog;
        return
        
    case 'vapp-error'
        terminate_program = 1;
        
        stdout_header = '[VAPP Error]';
        
        % Report to VALint
        index = length(valintLog)+1;
        
        valintLog{index}=[];
        valintLog{index}.infile_path = nodeinfo.filename;
        
        valintLog{index}.lineno = nodeinfo.lineno;
        valintLog{index}.linepos = nodeinfo.linepos;
        errOpts.valint_rule='';
        errOpts.rule_id = 0;
        errOpts.opt = 1;
        valintLog{index}.valint_msg = {errOpts.rule_id, 'error', errMsg, errOpts.rule_id, errOpts.opt};
        
    case 'vapp-warning'
        stdout_header = '[VAPP Warning]';
        
        % Report to VALint
        index = length(valintLog)+1;
        
        valintLog{index}=[];
        valintLog{index}.infile_path = nodeinfo.filename;
        
        valintLog{index}.lineno = nodeinfo.lineno;
        valintLog{index}.linepos = nodeinfo.linepos;
        errOpts.valint_rule='';
        errOpts.rule_id = 0;
        errOpts.opt = 1;
        valintLog{index}.valint_msg = {errOpts.rule_id, 'warning', errMsg, errOpts.rule_id, errOpts.opt};
        
    case 'vapp-notice'
        stdout_header = '[VAPP Notice]';
        
        % Report to VALint
        index = length(valintLog)+1;
        
        valintLog{index}=[];
        valintLog{index}.infile_path = nodeinfo.filename;
        
        valintLog{index}.lineno = nodeinfo.lineno;
        valintLog{index}.linepos = nodeinfo.linepos;
        errOpts.valint_rule='';
        errOpts.rule_id = 0;
        errOpts.opt = 1;
        valintLog{index}.valint_msg = {errOpts.rule_id, 'notice', errMsg, errOpts.rule_id, errOpts.opt};
        
    case 'lint-error'
        % VALint: error type
        stdout_header = '[Lint Error]';
        
        index = length(valintLog)+1;
        
        valintLog{index}=[];
        valintLog{index}.infile_path = nodeinfo.filename;
        
        valintLog{index}.lineno = nodeinfo.lineno;
        valintLog{index}.linepos = nodeinfo.linepos;
        valintLog{index}.valint_msg = {errOpts.rule_id, 'error', errMsg, errOpts.rule_id, errOpts.opt};
        
    case 'lint-warning'
        % VALint: warning type
        stdout_header = '[Lint Warning]';
        
        index = length(valintLog)+1;
        
        valintLog{index}=[];
        valintLog{index}.infile_path = nodeinfo.filename;
        
        valintLog{index}.lineno = nodeinfo.lineno;
        valintLog{index}.linepos = nodeinfo.linepos;
        valintLog{index}.valint_msg = {errOpts.rule_id, 'warning', errMsg, errOpts.rule_id, errOpts.opt};
        
    case 'lint-notice'
        % VALint: notice type
        stdout_header = '[Lint Notice]';
        
        index = length(valintLog)+1;
        
        valintLog{index}=[];
        valintLog{index}.infile_path = nodeinfo.filename;
        
        valintLog{index}.lineno = nodeinfo.lineno;
        valintLog{index}.linepos = nodeinfo.linepos;
        valintLog{index}.valint_msg = {errOpts.rule_id, 'notice', errMsg, errOpts.rule_id, errOpts.opt};
        
    otherwise
        
end

%% Do the following for all errors

% print error/warning message
fprintf('%-15s File: %15s. Line(s): %4d - %-4d\n', stdout_header, nodeinfo.filename, nodeinfo.lineno(1), nodeinfo.lineno(2));

if ~isempty(nodeinfo.origin_content)
    fprintf('    %s\n\n', nodeinfo.origin_content);
end

if terminate_program
    % Heading toward a hard error stop. Emit all lint results before error
    
    if exist('valint_print', 'file')
        valint_result = valint_make_print_struct(valintLog, {});
        valint_print(valint_result, 'nanoHUB');
    end
    
    error(['    ' errMsg]);
else
    fprintf('    %s\n\n', errMsg);
end

output = valintLog;

end % END of VAPP_error()

function nodeinfo = get_nodeinfo(errNode, nodeinfo)
% get node related information

switch class(errNode)
       
    case 'VAPP_AST_Node'
        % AST node
        nodeinfo.filename = errNode.get_pos{1}.infile_path;
        nodeinfo.lineno = errNode.get_pos{1}.lineno;
        nodeinfo.linepos = errNode.get_pos{1}.linepos;
        
    case 'struct'
        % likely a token from VAPP frontend
        %nodeinfo.origin_content = errNode.value;
        nodeinfo.filename = errNode.infile_path;
        nodeinfo.lineno = errNode.lineno;
        nodeinfo.linepos = errNode.linepos;
        
    otherwise
        try
            % likely a node from VAPP backend
            %nodeinfo.origin_content = errNode.sprintAll;
            nodeinfo.filename = errNode.getPosition{1}.infile_path;
            nodeinfo.lineno = errNode.getPosition{1}.lineno;
            nodeinfo.linepos = errNode.getPosition{1}.linepos;
        catch
            
        end
end
end




