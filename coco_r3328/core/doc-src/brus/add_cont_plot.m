function prob = add_cont_plot(prob, h)
prob = coco_add_slot(prob, 'utils.plot', @plot_bd, struct('h',h), 'cont_print');
end

function data = plot_bd(prob, data, command, varargin)
switch command
  case 'init'
    cla(data.h,'reset');
  case 'data'
    BD = prob.bd;
    PN = prob.bddat.op_names{1};
    NU = coco_bd_col(BD, '||x||_2,MPD');
    CP = coco_bd_col(BD, PN);
    cla(data.h);
    plot(data.h, CP, NU, 'b.-');
    drawnow
end
end
