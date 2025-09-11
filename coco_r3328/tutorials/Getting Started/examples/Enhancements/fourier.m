function y = fourier(data, xbp, ~, ~, ~)

mps = data.coll_seg.maps;
msh = data.coll_seg.mesh;
xcn = reshape(mps.W*xbp, mps.x_shp);
ecn = exp(-2i*data.n*pi*msh.tcn);
y   = (msh.fka.*msh.fwt.*xcn)*ecn/2/mps.NTST;

end
