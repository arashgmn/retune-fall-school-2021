This folder contains `.geo` files for mesh generation. You'll need an installation of [gmsh](https://gmsh.info) and [fenics](https://github.com/FEniCS).


# How to make meshes
## Generate `msh` files
Open the `geo` file of your choice from gmsh GUI and simply save the file as `.msh`. You can do the same with terminal as well.

**Note**: If you're using the GUI, make sure the mesh files are save as ASCII**2** (not default choice). Also leave all the checkboxes unchecked.

## Generate `.xml` files
Navigate to the this folder via terminal and execute the following command:

```
dolfin-convert <mesh_name>.msh <mesh_name>.xml
```

This should generate three `.xml` files for each mesh file (one with no suffix, and two others with `_facet_region` and `_physical_region` as suffix). These files are read from the notebooks.
