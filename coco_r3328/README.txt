This is a summary of the instructions found at
<https://sourceforge.net/p/cocotools/wiki/installation/>.

Installing and using COCO
=========================

1. Download the latest version from <https://sourceforge.net/projects/cocotools/files/latest/download>.

2. Move the package file to a location of your choice and uncompress the zip-file. This will create a 
   sub-directory with name coco that contains all files and will be referred to as PATH_TO_COCO in the 
   remainder of these instructions.

3. Change to the Matlab startup directory for your system (any folder returned by the Matlab-function 
   'userpath'). Create or open the file startup.m and add the line

	run PATH_TO_COCO/startup

where PATH_TO_COCO is the full path of the directory coco created in step 1.

4. Copy or move the file PATH_TO_COCO/coco_project_opts.m to the Matlab startup directory (the directory
   where the startup.m file created or modified in step 2 is located).

   Note: Do not add PATH_TO_COCO to the Matlab path!

5. After restarting Matlab, all coco toolboxes should now be in the search path.

Documentation
=============
Code documentation may in many cases be displayed by typing help followed by the function name on the 
command line. Additional documentation is also available in the textbook Recipes for Continuation.

For tutorial material, please see the following folders in the release.

Getting Started: introductory material for bifurcation analysis of equilibria and periodic orbits
                 -- examples in tutorials/Getting Started/
                 -- tutorial documentation in help/GettingStartedwithCOCO.pdf
ep             : continuation of equilibrium points
                 -- examples in ep/examples/
                 -- tutorial documentation in help/EP-Tutorial.pdf
coll           : continuation of constrained collections of trajectory segments
                 -- examples in coll/examples/
                 -- tutorial documentation in help/COLL-Tutorial.pdf
po             : continuation of periodic orbits in smooth and hybrid dynamical systems
                 -- examples in po/examples
                 -- tutorial documentation in help/PO-Tutorial.pdf
core           : core functionality and constructors
                 -- examples in core/examples/
                 -- tutorial documentation in help/CORE-Tutorial.pdf
atlas          : general-purpose atlas algorithms
                 -- examples in covering/examples/
                 -- tutorial documentation in help/ATLAS-Tutorial.pdf
symcoco        : symbolic generation of COCO-compatible encodings of vector fields and
                 their derivatives
                 -- examples in contributed/symcoco/examples/
                 -- tutorial documentation in contributed/symcoco/doc-src/symcoco-doc.pdf
recipes        : collection of examples from the book Recipes for Continuation, 
                 Society for Industrial and Applied Mathematics (SIAM), 2013. 
                 Use the Matlab-command 'doc recipes' to browse this content.

The ep, coll, and po toolbox examples were developed and verified in Matlab R2020b. The recipes
examples were developed in Matlab R2012b, and verified in Matlab R2020b. Inconsistencies between
releases and hardware platforms may result in some variations in the outputs.