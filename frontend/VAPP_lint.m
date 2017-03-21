function VAPP_lint(AST, IR, output_format)
% This function traverses through the AST and begin to check for poor
% Verilog-A practices

%==============================================================================
% This file is part of VAPP, the Berkeley Verilog-A Parser and Processor.
% Author: Xufeng Wang
% Last modified: Tue Feb 14, 2017  03:49PM
%==============================================================================

% Print tree structure
%valint_ast_print(AST,0);
        
% VALint check
valint_check(AST); % AST tree check
valint_new_ir(IR); % IR tree check

% VALint result structure
vapp_error_log = VAPP_error('nothing','','','');
valint_result = valint_make_print_struct(vapp_error_log, {});

% Print VALint result in certain format
valint_print(valint_result, output_format);

end % END of function lint_result

function valint_check(AST)
% this function checks the AST against a set of Verilog-A practice rules
%valint_debug_printinfo(AST);

% Rule book
valint_rules = {
 'valint_rule_parameter_range_needed'         % 1
%  'valint_rule_idt_not_allowed'                % 2
%  'valint_rule_constants_redefine'             % 3
%  'valint_rule_no_analysis'                    % 4
 'valint_rule_use_branch'                     % 5
%  'valint_rule_with_decimal'                   % 6
 'valint_rule_has_begin_end'                  % 7
 'valint_rule_notice_log_base_ten'            % 8
 'valint_rule_notice_limexp'                  % 9
%  'valint_rule_implicit_expression'            % 10
%  'valint_rule_no_event'                       % 11
%  'valint_rule_use_current_contrib'            % 12
%  'valint_rule_no_ddt_in_conditionals'         % 13
%  'valint_rule_no_both_potential_and_flow'     % 14
%  'valint_rule_no_division_of_int'             % 15
%  'valint_rule_no_reference_to_ground'         % 16
%  'valint_rule_no_ddx'                         % 17
%  'valint_rule_no_bitwise_and_shift_operators' % 18
};

% Check all rules
% fprintf('-----------------------------------------\n');
% fprintf('%s:\n',AST.get_type);
% AST.get_attrs

for index = 1:length(valint_rules)
    feval(valint_rules{index},AST);
end

if ~isempty(AST.get_children)
    % if children exists, recursively get each child
    for this_child = AST.get_children
        % for each child
        valint_check(this_child{1});
    end
end

end % END of function valint_check

function valint_result = valint_make_print_struct(vapp_error_log, valint_result)
% This function turns an AST tree into a special VALint print structure

if ~isempty(vapp_error_log)
    % this node has VAlint rule output
    
    for this_cell = vapp_error_log
        % for each VALint msg
        
        for index = 1:(length(valint_result)+1)
            
            if index == (length(valint_result)+1)
                % no existing matching file found
                valint_result{index}=[];
                valint_result{index}.infile_path = this_cell{1}.infile_path;
                
                valint_result{index}.lineno = [];
                valint_result{index}.linepos = [];
                valint_result{index}.valint_msg = {};
                valint_result{index}.rule_id = [];
                valint_result{index}.opt = [];
            end
            
            if strcmp(valint_result{index}.infile_path, this_cell{1}.infile_path)
                % existing matching file found
                valint_result{index}.lineno = [valint_result{index}.lineno; this_cell{1}.lineno];
                valint_result{index}.linepos = [valint_result{index}.linepos; this_cell{1}.linepos];
                valint_result{index}.valint_msg = {valint_result{index}.valint_msg{:}, this_cell{1}.valint_msg};
                
                break;
            end
        end
    end
end

% if ~isempty(AST.get_children)
%     % if children exists, recursively get each child
%     for this_child = AST.get_children
%         % for each child
%         valint_result = valint_make_print_struct(this_child{1}, valint_result);
%     end
% end

end % END of valint_make_print_struct

function valint_debug_printinfo(AST)
% print the node information
if ~isempty(AST.get_infile_path)
    s = VAPP_file_to_str(AST.get_infile_path);
end

range = AST.get_range;

fprintf('-----------------------------------------------------------------\n')
fprintf('Node %d: [%s], Type = %s, infile_path = %s\n', AST.get_uniqID, num2str(range), AST.get_type, AST.get_infile_path);
if ~isempty(range)
    fprintf('      Content: "%s"\n\n',s(range(1):range(2)));
end
end

function valint_ast_print(AST,level)
% print this AST
fprintf('%s(%d) Type: %s\n',' '.*ones(1,level*3), level, AST.get_type);
% AST.get_alias
% for this_attr = AST.get_attrs;
%     %fprintf('%s(%d) Attr: %s\n',' '.*ones(1,level*3), level, this_attr);
%     %this_attr
% end

if ~isempty(AST.get_children)
    % if children exists, recursively get each child
    for this_child = AST.get_children
        % for each child
        valint_ast_print(this_child{1},level+1);
    end
end
end
