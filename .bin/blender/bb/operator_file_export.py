import bpy
import json
import os
import bmesh
import hashlib
import random
import string

def p(stuff):
    self.report({'INFO'}, stuff)


# Define a property group to hold settings (like the path)
class MyToolsProperties(bpy.types.PropertyGroup):
    export_path: bpy.props.StringProperty(
        name="Export Path",
        description="Choose where to save the exported JSON file",
        default="//export.json",   # "//" = relative to blend file
        subtype='FILE_PATH'
    )

# Define the panel
class MYTOOLS_PT_sidebar(bpy.types.Panel):
    bl_label = "My Tools"
    bl_idname = "MYTOOLS_PT_sidebar"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = "My Tab"

    def draw(self, context):
        layout = self.layout
        props = context.scene.mytools_props

        layout.prop(props, "export_path")  # Draw the file path input
        layout.operator("wm.mytools_export", text="Export to JSON")


def seeded_hash(seed, length):
    chars = string.ascii_letters + string.digits  # A-Z, a-z, 0-9
    
    # Create a deterministic seed from the input
    h = hashlib.sha256(str(seed).encode()).hexdigest()
    seed_int = int(h, 16)  # Turn hash into an integer
    
    rng = random.Random(seed_int)  # Deterministic RNG
    
    return ''.join(rng.choice(chars) for _ in range(length))


def triangulate_object(obj):
    """Return (vertices, triangles) for a mesh object, triangulated."""
    if obj.type != 'MESH':
        return [], []

    # Make sure mesh data is up-to-date
    depsgraph = bpy.context.evaluated_depsgraph_get()
    eval_obj = obj.evaluated_get(depsgraph)
    mesh = eval_obj.to_mesh()

    # Build a BMesh from the evaluated mesh
    bm = bmesh.new()
    bm.from_mesh(mesh)

    # Triangulate all faces
    bmesh.ops.triangulate(bm, faces=bm.faces[:])

    # Extract vertex coordinates
    vertices = [v.co[:] for v in bm.verts]

    # Extract face indices (each face is now a triangle)
    faces = [[v.index for v in f.verts] for f in bm.faces]

    # Cleanup
    bm.free()
    eval_obj.to_mesh_clear()

    return vertices, faces


def export_bb4(data):
    pass    



def export_object(obj):
    """Recursively export an object and its children into dict form."""
    print(obj)
    if obj.type in {"MESH","EMPTY"}:
        if obj.type == "MESH":
            triangulate_object(obj)
        
        children_data = []
        for child in obj.children:
            child_data  = export_object(child)
            children_data.append(child_data)
    
    # Build JSON object for this node
    obj_data = {
        "name": obj.name,
        "children": children_data
    }
    
    return obj_data


# Define the export operator
class WM_OT_mytools_export(bpy.types.Operator):
    bl_label = "Export Scene to JSON"
    bl_idname = "wm.mytools_export"

    def execute(self, context):
        props = context.scene.mytools_props
        export_path = bpy.path.abspath(props.export_path)  # Resolve relative paths

        # Make sure the directory exists
        os.makedirs(os.path.dirname(export_path), exist_ok=True)

        # Simple Hello World JSON
        data = {"message": "Hello, World!"}

        try:
            roots = []
            for obj in bpy.context.scene.objects:
                if obj.parent is None and obj.type in {"MESH", "EMPTY"}:
                    if obj is not None:
                        roots.append(obj)
            
            data = [export_object(obj) for obj in roots]
            with open(export_path, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=4)
            self.report({'INFO'}, f"Exported JSON to {export_path}")
        except Exception as e:
            self.report({'ERROR'}, f"Failed to export: {e}")
            return {'CANCELLED'}

        return {'FINISHED'}


# Registration
classes = (
    MyToolsProperties,
    MYTOOLS_PT_sidebar,
    WM_OT_mytools_export,
)

def register():
    for cls in classes:
        bpy.utils.register_class(cls)
    bpy.types.Scene.mytools_props = bpy.props.PointerProperty(type=MyToolsProperties)

def unregister():
    for cls in reversed(classes):
        bpy.utils.unregister_class(cls)
    del bpy.types.Scene.mytools_props

if __name__ == "__main__":
    register()
