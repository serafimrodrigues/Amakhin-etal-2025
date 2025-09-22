function [options,passed_on,userdefined]=dde_set_options(defaults,userargs,pass_on,extra_optname,extra_as_defined)
%% parses varargin and assigns fields of structure options
% arguments not present in defaults are passed on into cell array passed_on
% if pass_on is present and (non-empty or false), otherwise an error
% message is generated; userdefined returns a structure indicating which
% options have been set by userargs. If extra_optname is present, an additional
% check is performed: if one of the names in userargs is extra_optname and its
% value is a struct, use the fields of this struct to replace those options
% that have not been set by userargs. Fields in extra_optname that do not show up
% in defaults are passed on into passed_on. This permits overwriting
% defaults from the level above.
%
% Userargs can also be a struct. In this case, fields showing up in
% defaults are put into options.
%
% $Id: dde_set_options.m 315 2019-01-29 19:42:21Z jansieber $
%
passed_on={};
%% prepopulate options with defaults
% wrap cell arguments to avoid generating multiple structs
alternatives=cell(0,2);
if isstruct(defaults)
    options=defaults;
elseif iscell(defaults)
    altcount=0;
    for i=1:length(defaults)
        if mod(i,2)==0 && iscell(defaults{i})
            defaults{i}=defaults(i);
        end
        if mod(i,2)==1 && iscell(defaults{i})
            altcount=altcount+1;
            alternatives{altcount,1}=defaults{i}{1};
            alternatives{altcount,2}=defaults{i}(2:end);
            defaults{i}=defaults{i}{1};
        end
    end
    options=struct(defaults{:});
    for i=1:altcount
        for k=1:length(alternatives{i,2})
            options.(alternatives{i,2}{k})=options.(alternatives{i,1});
        end
    end
else
    error('defaults not recognized\n');
end
%% Initialize fields in userdefined as false
userdefined=[fieldnames(options),num2cell(zeros(length(fieldnames(options)),1))]';
userdefined=struct(userdefined{:});
%% check if unknown arguments should throw error
if nargin<3 || isempty(pass_on)
    pass_on=false;
end
if nargin<4
    extra_optname='';
end
if nargin<5
    extra_as_defined=false;
end
extra_optvalue=struct();
if length(userargs)~=1
    %% userargs input is cell
    for i=1:2:length(userargs)
        if isfield(options,userargs{i})
            options.(userargs{i})=userargs{i+1};
            userdefined.(userargs{i})=i+1;
        elseif strcmp(userargs{i},extra_optname)
            extra_optvalue=userargs{i+1};
        else
            if ~pass_on
                error('option ''%s'' not recognized\n',userargs{i});
            elseif nargout>1
                passed_on={passed_on{:},userargs{i},userargs{i+1}}; %#ok<CCAT>
            end
        end
    end
else
    %% userargs input is struct
    userargs=userargs{1};
    if ~isstruct(userargs)
        error('option ''%s'' not recognized\n',userargs{i});
    end
    passed_on={};
    usernames=fieldnames(userargs);
    for i=1:length(usernames)
        if isfield(options,usernames{i})
            options.(usernames{i})=userargs.(usernames{i});
            if extra_as_defined
                userdefined.(usernames{i})=i;
            end
        elseif strcmp(usernames{i},extra_optname)
            extra_optvalue=userargs.(usernames{i});
        elseif nargout>1
            passed_on={passed_on{:},usernames{i},userargs.(usernames{i})}; %#ok<CCAT>
        end
    end
end
%% check if argument optname is present
% if yes and one of the userargs names was optname
if ~isempty(fieldnames(extra_optvalue))
    check=setdiff(intersect(fieldnames(extra_optvalue),fieldnames(options)),{extra_optname});
    for i=1:length(check)
        if userdefined.(check{i})==0
            options.(check{i})=extra_optvalue.(check{i});
            if extra_as_defined
                userdefined.(check{i})=1/(length(check)+1);
            end
        end
    end
    check=setdiff(fieldnames(extra_optvalue),fieldnames(options));
    add_pass=cell(1,2*length(check));
    for i=1:length(check)
        add_pass(2*i+(-1:0))={check{i},extra_optvalue.(check{i})};
    end
    if nargout>1
        passed_on=[passed_on,add_pass];
    end
end
%% reassign and remove alternatives from options
for i=1:size(alternatives,1)
    for k=1:length(alternatives{i,2})
        if userdefined.(alternatives{i,2}{k})>userdefined.(alternatives{i,1})
            options.(alternatives{i,1})=options.(alternatives{i,2}{k});
            userdefined.(alternatives{i,1})=userdefined.(alternatives{i,2}{k});
            options=rmfield(options,alternatives{i,2}{k});
            userdefined=rmfield(userdefined,alternatives{i,2}{k});
        else
            options=rmfield(options,alternatives{i,2}{k});
            userdefined=rmfield(userdefined,alternatives{i,2}{k});
        end
    end
end
if nargout<3
    return
end
%% reassign userdefined to integers
names=fieldnames(userdefined);
userdefined_values=cellfun(@(s)userdefined.(s),names);
isdefined=find(userdefined_values>0);
[~,ix]=sort(userdefined_values(isdefined));
for i=1:length(ix)
    userdefined.(names{isdefined(ix(i))})=i;
end
end
