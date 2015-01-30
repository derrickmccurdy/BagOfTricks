find Desktop/david\ for\ Derrick/ -name "*.doc" -exec antiword '{}' \; | grep -E "[^\s]+@[^\s]+" | sort | uniq > /tmp/david_addys.txt

antiword Desktop/david\ for\ Derrick/clients/broadcasts/Lena\ Tali\ -\ 111308.doc | grep -E "[^\s]+@[^\s]+"
