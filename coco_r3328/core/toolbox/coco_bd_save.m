function prob = coco_bd_save(prob)
  [prob, fids, data] = coco_emit(prob, 'save_bd');
  bd_data = [ fids data ]; 
  version = 1; 
	save(prob.run.bdfname, 'version', 'bd_data');
end
