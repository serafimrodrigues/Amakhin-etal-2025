classdef coco_stream < handle
%COCO_STREAM   Convert argument array to stream object.
% 
% COCO_STREAM([STREAM], VARARGIN)
%
% appends the argument array VARARGIN (which cannot contain a coco_stream
% object) to an existing coco_stream object given in the optional STREAM
% argument or to an initialized anonymous coco_stream object if the STREAM
% argument is absent.
%
% A stream object is a cell array 'token' of tokens of length 'ntok' with
% an integer index 'pos' corresponding to the position of the next token to
% be read or equal to 'ntok'+1 if all tokens have been read.
%
% Ordinary methods:
%
% peek    : read the next token without advancing the stream. If called
%           with the argument 'cell', then return a cell array with the
%           next token as the single element if it isn't already a cell
%           array.
%
% get     : read the next one or more tokens and advance the stream the
%           corresponding number of step. If called with the argument
%           'cell', then return a cell array with each read token as the
%           single element if it isn't already a cell array.
%
% put     : insert one or more tokens before the next token to be read
%           without advancing the stream.
%
% skip    : advance the stream one or more steps without reading tokens.
%
% isempty : return true if all tokens have been read and false otherwise.
%
% numel   : return number of tokens left to be read. 
%
% tell    : return the index of the next token to be read or 'ntok'+1 if
%           all tokens have been read.
%
% seek    : set the index of the next token to be read.
%
% disp    : display a representation of the stream object in terms of the
%           tokens that are left to be read.
  
  properties ( Access = private )
    tokens = {}
    ntok   = 0;
    pos    = 1;
  end
  
  methods
    
    function p = coco_stream(varargin)
      if nargin>=1 && isa(varargin{1}, 'coco_stream')
        p        = varargin{1};
        p.tokens = [ p.tokens varargin{2:end} ];
      else
        p.tokens = varargin;
      end
      p.ntok = numel(p.tokens);
    end
    
    function t = peek(p, varargin)
      if p.pos<=p.ntok
        t = p.tokens{p.pos};
      else
        t = [];
      end
      if nargin>=2 && ~iscell(t) && strcmp('cell', varargin{1})
        t = { t };
      end
    end
    
    function varargout = get(p, varargin)
      for i=1:max(1,nargout)
        varargout{i} = p.peek(varargin{:}); %#ok<AGROW>
        p.pos        = min(p.pos,p.ntok)+1;
      end
    end
    
    function p = put(p, varargin)
      p.tokens = [p.tokens(1:(p.pos-1)) varargin p.tokens(p.pos:end)];
      p.ntok   = numel(p.tokens);
    end
    
    function skip(p, n)
      if nargin>1
        p.pos = min(p.pos+n,p.ntok+1);
      else
        p.pos = min(p.pos+1,p.ntok+1);
      end
    end
    
    function flag = isempty(p)
      flag = p.pos>p.ntok;
    end
    
    function n = numel(p)
      n = p.ntok-p.pos+1;
    end
    
    function idx = tell(p)
      idx = p.pos;
    end
    
    function p = seek(p, idx)
      p.pos = max(1, min(idx, p.ntok+1));
    end
    
    function disp(p)
      disp('stream =');
      disp(p.tokens(p.pos:end))
    end
  end
  
end
