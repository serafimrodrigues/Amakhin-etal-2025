function prob = add_po_monitor(prob)
[data uidx] = init_data(prob);

prob = coco_add_func(prob, 'uzr_tst', @F, @DF, ...
  data, 'active', {'uzr.mean' 'uzr.dev'}, ...
  'uidx', uidx, 'remesh', @remesh);

end

function [data y] = F(prob, data, u) %#ok
xbp = reshape(u, data.xbp_shp);
xav = sum(reshape(data.w(:).*(data.W*xbp(:)), data.x_shp),2);
dev = xbp-repmat(xav, [1 data.xbp_shp(2)]);

y   = [ sqrt(sum(xav.^2)) ; sqrt(data.w*((data.W*dev(:)).^2)) ];
end

function [data J] = DF(prob, data, u) %#ok
xbp = reshape(u, data.xbp_shp);
xav = sum(reshape(data.w(:).*(data.W*xbp(:)), data.x_shp),2);
dev = xbp-repmat(xav, [1 data.xbp_shp(2)]);

nxav = sqrt(sum(xav.^2));
ndev = sqrt(data.w*((data.W*dev(:)).^2));

xav2 = repmat(xav, [1 data.x_shp(2)]);
Dxav = (xav2(:)'.*data.w)*data.W;

Ddev2 = (data.w.*(data.W*dev(:))')*data.W;

J = [ Dxav/nxav ; Ddev2/ndev ];

% To check correctness of explicit derivatives, use finite difference
% approximation for comparison. A difgference larger than 1.0e-4 .. 1.0e-3
% indicates an error.
% [data, J2] = coco_ezDFDX('f(o,d,x)', prob, data, @F, u);
% max(max(abs(J(2,:)-J2(2,:)))) < 1.0e-6
end

function [prob, status, xtr] = remesh(prob, data, chart, old_u, old_V) %#ok<INUSD>
[data uidx] = init_data(prob);

xtr       = [];
prob      = coco_change_func(prob, data, 'uidx', uidx);
status    = 'success';

end

function [data uidx] = init_data(prob)
[fdata, uidx] = coco_get_func_data(prob, 'po.orb.coll', 'data', 'uidx');
maps  = fdata.coll_seg.maps;
mesh  = fdata.coll_seg.mesh;

uidx = uidx(maps.xbp_idx);

W = (0.5/maps.NTST)*mesh.kas2*mesh.wts2;
O = ones(1,prod(maps.x_shp));
data.W = maps.W;
data.w = O*W;
data.x_shp = maps.x_shp;
data.xbp_shp = maps.xbp_shp;
end
