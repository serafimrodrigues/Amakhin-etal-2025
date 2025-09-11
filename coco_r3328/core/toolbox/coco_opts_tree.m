classdef coco_opts_tree
%COCO_OPTS_TREE   COCO options tree for maintaining problem settings.
%
% A COCO options tree is a rooted tree in which every rooted subtree is a
% coco_opts_tree object. The root of each subtree contains a struct PROPS
% of properties together with corresponding values, and a struct PATHS of
% unique names for its child nodes togetherwith the corresponding
% descendant trees. By concatenation of such labels with the delimiter '.',
% one may uniquely identify individual nodes in the tree, provided that the
% root is identified with the empty string.
%
% Three modes apply to the inheritance of property values in a COCO options
% tree:
%
% '-no-inherit'     : a property value may be associated with a node only
%                     if the property is included in the corresponding
%                     struct PROPS.
%
% '-no-inherit-all' : a property value may be associated with a node if
%                     either 1) the property is included in the
%                     corresponding struct PROPS or 2) the property is
%                     included in the struct PROPS of an identically named
%                     child of a direct ancestor of the node, in that order
%                     and in case 2) with value corresponding to the
%                     nearest such ancestor.
%
% '-inherit'        : a property value may be associated with a node if
%                     either 1) the property is included in the
%                     corresponding struct PROPS or 2) the property is
%                     included in the struct PROPS of an identically named
%                     child of a direct ancestor of the node or 3) the
%                     property is included in the struct PROPS of a direct
%                     ancestor of the node, in that order and in cases 2)
%                     and 3) with value corresponding to the nearest such
%                     ancestor.
%
% Static methods:
%
% check_path       : return true if argument is a allowable path and
%                    false otherwise.
%
% check_field_name : throw an error if argument is not a allowable field
%                    name.
%
% is_inherit_mode  : return true if argument is a valid inherit mode and
%                    false otherwise.
%
% inherit_level    : return the integer 0, 1, or 2, if the argument is
%                    '-no-inherit', '-no-inherit-all', or '-inherit' and
%                    throw an error otherwise.
%
% merge            : recursive overwrite of a selected subset of the fields
%                    of a struct B onto the corresponding fields of a
%                    struct A.
%
% Ordinary methods:
%
% path_add         : add new path PATH to an existing tree.
%
% path_exist       : return true if path PATH exists and false otherwise,
%                    unless the inheritance mode INHERIT is
%                    '-no-inherit-all' or '-inherit' and the terminal field
%                    name exists at the level where the first path
%                    violation occurred. The second output argument is the
%                    terminal field name.
%
% prop_set         : assign a value VAL to a property PROP at the node
%                    identified by the path PATH. If PROP is empty, VAL
%                    must be a struct that contains property names and
%                    values.
%
% prop_get         : return a value VAL for a property PROP at the node
%                    identified by the path PATH per the inheritance
%                    paradigm described above. If PROP is empty, VAL is the
%                    PROPS struct for the node merged into the
%                    corresponding PROPS structs for an identically named
%                    child of a direct ancestor and for such a direct
%                    ancestor, per the inheritance paradigm described
%                    above. If the PATH does not exist in the options tree,
%                    then VAL is obtained by applying this algorithm to a
%                    virtual node identified by PATH with empty PROPS.
%
% prop_exist       : returns true if a value can be obtained using prop_get
%                    for property PROP at the node identified by the path
%                    PATH and false otherwise.
%                    
% print_tree       : print tree to output stream FID with root label ROOT
%                    and property values visible if VAL_FLAG is true and
%                    not otherwise.

  properties ( Access = private )
    props = struct()
    paths = struct()
  end
  
  methods
    
    function p = coco_opts_tree(path)
      if nargin>=1 && ~isempty(path)
        [field, remain] = strtok(path, '.');
        p.paths.(field) = coco_opts_tree(remain);
      end
    end
    
    function p = path_add(p, path)
      coco_opts_tree.check_path(path);
      if ~isempty(path)
        [field, remain] = strtok(path, '.');
        if isfield(p.paths, field)
          p.paths.(field) = p.paths.(field).path_add(remain);
        else
          p.paths.(field) = coco_opts_tree(remain);
        end
      end
    end
    
    function [flag, field] = path_exist(p, path, inherit)
      if nargin<3
        inherit = 2;
      end
      
      if isempty(path)
        flag = true;
      else
        [field, remain] = strtok(path, '.');
        coco_opts_tree.check_field_name(field);
        inherit = coco_opts_tree.inherit_level(inherit);
        if isfield(p.paths, field)
          if isempty(remain)
            flag = true;
          else
            [flag, field] = p.paths.(field).path_exist(remain, min(1,inherit));
            flag = flag || (inherit~=0 && isfield(p.paths, field));
          end
        else
          while ~isempty(remain)
            [field, remain] = strtok(remain, '.'); %#ok<STTOK>
          end
          flag = false;
        end
      end
    end
    
    function p = prop_set(p, path, prop, val)
      if isempty(path)
        p.props = p.prop_set_rec(p.props, prop, val);
      else
        [field, remain] = strtok(path, '.');
        coco_opts_tree.check_field_name(field);
        if ~isfield(p.paths, field)
          p.paths.(field) = coco_opts_tree(remain);
        end
        if isempty(remain)
          p.paths.(field).props = p.prop_set_rec(p.paths.(field).props, prop, val);
        else
          p.paths.(field) = p.paths.(field).prop_set(remain, prop, val);
        end
      end
    end
    
    function [val, flag, field] = prop_get(p, path, prop, inherit)
      if nargin<4
        inherit = 2;
      end
      
      if isempty(path)
        [val, flag] = p.prop_get_rec(p.props, prop);
        field = '';
      else
        [field, remain] = strtok(path, '.');
        coco_opts_tree.check_field_name(field);
        inherit = coco_opts_tree.inherit_level(inherit);
        if isfield(p.paths, field)
          if isempty(remain)
            [val, flag] = p.prop_get_rec(p.paths.(field).props, prop);
          else
            [val, flag, field] = p.paths.(field).prop_get(remain, prop, min(1,inherit));
            if inherit~=0 && isfield(p.paths, field) ...
                && p.isfield_rec(p.paths.(field).props, prop)
              if ~flag
                [val, flag] = p.prop_get_rec(p.paths.(field).props, prop);
              elseif isstruct(val)
                val2 = p.prop_get_rec(p.paths.(field).props, prop);
                if isstruct(val2)
                  val = p.merge(val2, val);
                end
              end
            end
          end
        else
          while ~isempty(remain)
            [field, remain] = strtok(remain, '.'); %#ok<STTOK>
          end
          if inherit~=0 && isfield(p.paths, field) ...
              && p.isfield_rec(p.paths.(field).props, prop)
            [val, flag] = p.prop_get_rec(p.paths.(field).props, prop);
          else
            val  = [];
            flag = false;
          end
        end
        if inherit==2
          if ~flag
            val = p.prop_get_rec(p.props, prop);
          elseif isstruct(val)
            val2 = p.prop_get_rec(p.props, prop);
            if isstruct(val2)
              val = p.merge(val2, val);
            end
          end
        end
      end
    end
    
    function [flag, field] = prop_exist(p, path, prop, inherit)
      if nargin<4
        inherit = 2;
      end
      
      if isempty(path)
        flag = p.isfield_rec(p.props, prop);
      else
        [field, remain] = strtok(path, '.');
        coco_opts_tree.check_field_name(field);
        inherit = coco_opts_tree.inherit_level(inherit);
        if isfield(p.paths, field)
          if isempty(remain)
            flag = p.isfield_rec(p.paths.(field).props, prop);
          else
            [flag, field] = p.paths.(field).prop_exist(remain, prop, min(1,inherit));
            flag = flag || (inherit~=0 && isfield(p.paths, field) ...
              && p.isfield_rec(p.paths.(field).props, prop));
          end
        else
          while ~isempty(remain)
            [field, remain] = strtok(remain, '.'); %#ok<STTOK>
          end
          flag = false || (inherit~=0 && isfield(p.paths, field) ...
            && p.isfield_rec(p.paths.(field).props, prop));
        end
        flag = flag || (inherit==2 && p.isfield_rec(p.props, prop));
      end
    end
    
    function print_tree(p, varargin)
      % varargin = [fhan] root [val_flag]
      
      s = coco_stream(varargin{:});
      if ~isempty(s) && isnumeric(s.peek)
        fhan = s.get;
      else
        fhan = 1;
      end
      assert(~isempty(s) && ischar(s.peek), '%s: %s', mfilename, ...
        'missing root label');
      root = s.get;
      if ~isempty(s) && (islogical(s.peek) || isnumeric(s.peek))
        val_flag = s.get;
      else
        val_flag = false;
      end
      fprintf(fhan, '%s', root);
      p.print_prop_names(fhan, val_flag);
      fprintf(fhan, '\n');
      p.print_tree_rec(fhan, '+-', '  ', val_flag);
    end
    
  end
  
  methods (Access=private)
    
    function print_tree_rec(p, fhan, prefix, indent, val_flag)
      ch_ind1  = [ indent '| ' ];
      ch_ind2  = [ indent '  ' ];
      children = fieldnames(p.paths);
      N        = numel(children);
      for i=1:N-1
        child = children{i};
        fprintf(fhan, '%s%s%s', indent, prefix, child);
        p.paths.(child).print_prop_names(fhan, val_flag);
        fprintf(fhan, '\n');
        p.paths.(child).print_tree_rec(fhan, '+-', ch_ind1, val_flag);
      end
      if N>0
        child = children{N};
        fprintf(fhan, '%s%s%s', indent, prefix, child);
        p.paths.(child).print_prop_names(fhan, val_flag);
        fprintf(fhan, '\n');
        p.paths.(child).print_tree_rec(fhan, '+-', ch_ind2, val_flag);
      end
    end
    
    function print_prop_names(p, fhan, val_flag)
      names = fieldnames(p.props);
      N = numel(names);
      if N>0
        fprintf(fhan, ': {');
        for i=1:N
          fprintf(fhan, ' %s', names{i});
          if val_flag
            val = p.props.(names{i});
            if isstruct(val)
              fprintf(fhan, '=struct');
            elseif ischar(val)
              fprintf(fhan, '=''%s''', val);
            elseif iscellstr(val) %#ok<ISCLSTR>
              fprintf(fhan, '={ ');
              for k=1:numel(val)
                fprintf(fhan, '''%s'' ', val{k});
              end
              fprintf(fhan, '}');
            elseif isnumeric(val)
              if numel(val)==1
                fprintf(fhan, '=%g', val);
              else
                fprintf(fhan, '=num.array');
              end
            elseif islogical(val)
              if numel(val)==1
                if val
                  fprintf(fhan, '=true');
                else
                  fprintf(fhan, '=false');
                end
              else
                fprintf(fhan, '=log.array');
              end
            elseif iscell(val)
              fprintf(fhan, '=cell.array');
            else
              fprintf(fhan, '=%s', class(val));
            end
          end
        end
        fprintf(fhan, ' }');
      end
    end
    
  end
  
  methods (Access=public, Static)
    
    function A = merge(A, B, filter)
      if ~isstruct(A)
        A = struct();
      end
      if ~isstruct(B)
        B = struct();
      end
      fields = fieldnames(B);
      if nargin>=3
        fields = intersect(fields, filter);
      end
      for i=1:length(fields)
        field = fields{i};
        if isfield(A, field)
          if isstruct(A.(field)) && isstruct(B.(field))
            A.(field) = coco_opts_tree.merge(A.(field), B.(field));
          else
            A.(field) = B.(field);
          end
        else
          A.(field) = B.(field);
        end
      end
    end
    
    function l = inherit_level(l)
      if ischar(l)
        idx = strcmpi(l, { '-no-inherit' '-no-inherit-all' '-inherit' });
        if any(idx)
          l = find(idx)-1;
        else
          error('%s: invalid inherit mode ''%s''', mfilename, l);
        end
      end
    end
    
    function flag = is_inherit_mode(mode)
      flag = any(strcmpi(mode, { '-no-inherit' '-no-inherit-all' '-inherit' }));
    end
    
    function check_path(path)
      try
        if ~isempty(path)
          [field, remain] = strtok(path, '.');
          coco_opts_tree.check_field_name(field);
          if ~isempty(remain)
            coco_opts_tree.check_path(remain);
          end
        end
      catch e
        error('%s', e.message);
      end
    end
    
    function check_field_name(name)
      dummy.(name) = []; %#ok<STRNU>
    end
    
  end
  
  methods (Access=private, Static)
    
    function props = prop_set_rec(props, path, val)
      coco_opts_tree.check_path(path);
      if isempty(path)
        if isstruct(val)
          props = val;
        else
          error('%s: full class property must be a struct', mfilename);
        end
      else
        [field, remain] = strtok(path, '.');
        if isempty(remain)
          props.(field) = val;
        else
          if isfield(props, field)
            props.(field) = coco_opts_tree.prop_set_rec(props.(field), remain, val);
          else
            props.(field) = coco_opts_tree.prop_set_rec(struct(), remain, val);
          end
        end
      end
    end
    
    function [val, flag] = prop_get_rec(props, path)
      coco_opts_tree.check_path(path);
      if isempty(path)
        val  = props;
        flag = true;
      else
        [field, remain] = strtok(path, '.');
        if isfield(props, field)
          if isempty(remain)
            val  = props.(field);
            flag = true;
          else
            [val, flag] = coco_opts_tree.prop_get_rec(props.(field), remain);
          end
        else
          val  = [];
          flag = false;
        end
      end
    end
    
    function flag = isfield_rec(props, path)
      coco_opts_tree.check_path(path);
      if isempty(path)
        flag = true;
      else
        [field, remain] = strtok(path, '.');
        if isfield(props, field)
          if isempty(remain)
            flag = true;
          else
            flag = coco_opts_tree.isfield_rec(props.(field), remain);
          end
        else
          flag = false;
        end
      end
    end
    
  end
  
end
