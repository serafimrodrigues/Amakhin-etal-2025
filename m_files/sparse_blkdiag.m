function A=sparse_blkdiag(M,varargin)
%%sparse_blkdiag: create blockdiagonal sparse matrices
%
% function A=sparse_blkdiag(M,[shift[,clen]])
%
% puts n1xn2xn3 array M into a block diagonal sparse matrix whith the blocks
% M(:,:,i). If the argument shift is present then the row indices are all
% increased by shift(1) and the column indices are increased by n(2),
% allowing to create subdiagonals. If clen is present the blocks are
% treated as having only length clen, allowing for column overlap between
% the blocks
%
%
% $Id: sparse_blkdiag.m 296 2018-09-24 21:36:56Z jansieber $
%
%% input is 3d mshape structure
if isempty(varargin)
    shift=[0,0];
else
    shift=varargin{1};
end
if length(varargin)==2
    clen=varargin{2};
else
    clen=[];
end
if isstruct(M) && isfield(M,'sz') && isfield(M,'ir') && isfield(M,'vals')
    if isempty(clen)
        clen=M.sz(2);
    end
    A=spblkdiag(M,shift,clen);
    return
end
%% full 3d array
[n1,n2,n3]=size(M);
if isempty(clen)
    clen=n2;
end
% row indices
ri1=repmat((1:n1)',1,n2);
ri1=reshape(repmat(ri1,[1,1,n3]),[n1,n2*n3]);
ri2=n1*(shift(1)+repmat((0:n3-1),n1*n2,1));
%column indices
ci1=repmat(1:n2,n1,1);
ci1=reshape(repmat(ci1,[1,1,n3]),[n1,n2*n3]);
ci2=clen*(shift(2)+repmat((0:n3-1),n1*n2,1));
%assemble sparse matrix
A=sparse(ri1(:)+ri2(:),ci1(:)+ci2(:),M(:),n1*(n3+shift(1)),clen*(n3+shift(2)-1)+n2,n1*n2*n3);
end
function A=spblkdiag(M,shift,clen)
ircM=mshape(M,'irc');
ircMs=ircM(:,[1,3,2,3]);
Ms=mshape(M,'struct');
Ms.sz=Ms.sz([1,3,2,3]);
sz=Ms.sz;
ir=ircMs(:,1)+sz(1)*(shift(1)+ircMs(:,2)-1);
ic=ircMs(:,3)+clen*(shift(2)+ircMs(:,4)-1);
A=sparse(ir,ic,M.vals,sz(1)*(sz(2)+shift(1)),clen*(shift(2)+sz(4))+sz(3)-clen);
end