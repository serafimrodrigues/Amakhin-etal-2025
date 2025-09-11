function prob = coco_global_opts(prob)
%COCO_GLOBAL_OPTS  Set system wide defaults for COCO.
%
% Use coco_set in this function to set defaults that will apply to any
% instance of COCO run on this file system. This is also the place to
% define further functions to be executed on construction of a COCO
% continuation problem structure. A project specific function
% coco_project_opts will be executed after coco_global_opts, if it exists
% in the current working directory.
end
