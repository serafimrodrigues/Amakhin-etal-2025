function itcoarse=dde_coll_subinterval(tcoarse,x,submesh_limit)
%% return index of subinterval in coarse mesh tcoarse where x is located
%
% Argument submesh_limit determines into which interval to put x if it is
% exactly on the boundary (important for evaluation of discontinuous
% functions and for collocation methods that have collocation points on the
% boundary (e.g. RADAU type)). Only submesh_limit==1 gets special treatment
%
% function is vectorised: returning 1 x nx integers if given a 1 x nx input
% in x
%
% if x<tcoarse(1), itcoarse=0
% if x>tcoarse(end), itcoarse=nt+1 (nt=length(tcoarse)-1)
% if x==tcoarse(end), itcoarse=nt (!)
% if x==tcoarse(1), itcoarse=1 (always, regardless of submesh_limit)
itcoarse=NaN(size(x));
nt=length(tcoarse);
itcoarse(x<tcoarse(1))=0;
itcoarse(x>tcoarse(end))=nt+1;
itcoarse(x==tcoarse(end))=nt;
sel=x>=tcoarse(1)&x<tcoarse(end);
itcoarse(sel)=floor(interp1(tcoarse,1:nt,x(sel),'linear'));
itcoarse(itcoarse==length(tcoarse))=length(tcoarse)-1;
if submesh_limit==1
    ixch= x-tcoarse(itcoarse)==0 & x>0;
    itcoarse(ixch)=itcoarse(ixch)-1;
end
end
