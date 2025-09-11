function fstruc=fstruct_from_fgen(G,deriv)
fstruc=struct('F',G(''),'DFDP',G('p'),'DFDX',G('x'),'DFDt',G('t'),'DFDT',G('T'),...
    'DFDXDX',G({'x','x'}),'DFDXDP',G({'x','p'}),'DFDPDP',G({'p','p'}),...
    'DFDtDX',G({'t','x'}),'DFDtDP',G({'t','p'}),'DFDtDt',G({'t','t'}),...
    'DFDtDT',G({'t','T'}),'DFDXDT',G({'x','T'}),'DFDPDT',G({'p','T'}),'DFDTDT',G({'T','T'}));
if nargin<2
    deriv=0;
end
fstruc.deriv=deriv;
end
