function fmt=arg_preprocess_derivative(fun,deg,debug)
fmt.deg=deg;
fmt.nargs=fun('nargs');
fmt.args_exp=(1+(deg>0))*fmt.nargs;
fmt.argsize_exp=reshape(cell2mat(struct2cell(fun('argsize'))),1,[]);
fmt.isvec=cell2mat(struct2cell(fun('vector')));
fmt.debug=debug;
end