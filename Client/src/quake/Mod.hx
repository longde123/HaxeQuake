package quake;

import js.html.ArrayBuffer;
import js.html.DataView;
import js.html.Float32Array;
import js.html.Uint32Array;
import js.html.Uint8Array;
import js.html.webgl.RenderingContext;
import js.html.webgl.Buffer;
import js.html.webgl.Texture;
import quake.GL.gl;
import quake.GL.GLTexture;

// TODO this is a mess - there are 3 types of models and we should have classes for each one specifically

@:enum abstract MModelType(Int) {
    var brush = 0;
    var sprite = 1;
    var alias = 2;
}

@:enum abstract ModelVersion(Int) to Int {
    var brush = 29;
    var sprite = 1;
    var alias = 6;
}

private class ModelLumpOffsets {
    public static inline var entities     = (0 << 3) + 4;
    public static inline var planes       = (1 << 3) + 4;
    public static inline var textures     = (2 << 3) + 4;
    public static inline var vertexes     = (3 << 3) + 4;
    public static inline var visibility   = (4 << 3) + 4;
    public static inline var nodes        = (5 << 3) + 4;
    public static inline var texinfo      = (6 << 3) + 4;
    public static inline var faces        = (7 << 3) + 4;
    public static inline var lighting     = (8 << 3) + 4;
    public static inline var clipnodes    = (9 << 3) + 4;
    public static inline var leafs        = (10 << 3) + 4;
    public static inline var marksurfaces = (11 << 3) + 4;
    public static inline var edges        = (12 << 3) + 4;
    public static inline var surfedges    = (13 << 3) + 4;
    public static inline var models       = (14 << 3) + 4;
}

@:publicFields
class MModel {
    var flags:ModelEffect;
    var oriented:Bool;
    var numframes:Int;
    var frames:Array<MFrame>;
    var boundingradius:Float;
    var player:Bool;
    var numtris:Int;
    var cmds:Buffer;
    var numskins:Int;
    var skins:Array<MSkin>;
    var type:MModelType;
    var mins:Vec;
    var maxs:Vec;
    var radius:Float;
    var submodel:Bool;
    var submodels:Array<MModel>;
    var lightdata:Uint8Array;
    var chains:Array<Array<Int>>;
    var textures:Array<MTexture>;
    var waterchain:Int;
    var skychain:Int;
    var leafs:Array<MLeaf>;
    var numfaces:Int;
    var faces:Array<MSurface>;
    var firstface:Int;
    var marksurfaces:Array<Int>;
    var texinfo:Array<MTexinfo>;
    var name:String;
    var vertexes:Array<Vec>;
    var edges:Array<Array<Int>>;
    var surfedges:Array<Int>;
    var visdata:Uint8Array;
    var random:Bool;
    var nodes:Array<MNode>;
    var hulls:Array<MHull>;
    var entities:String;
    var needload:Bool;
    var scale:Vec;
    var scale_origin:Vec;
    var skinwidth:Int;
    var skinheight:Int;
    var numverts:Int;
    var stverts:Array<MSTVert>;
    var triangles:Array<MTriangle>;
    var width:Int;
    var height:Int;
    var planes:Array<Plane>;
    var clipnodes:Array<MClipNode>;
    var origin:Vec;

    function new(name:String) {
        this.name = name;
        this.needload = true;
    }
}

@:publicFields
class MSTVert {
    var onseam:Bool;
    var s:Int;
    var t:Int;
    function new(onseam, s, t) {
        this.onseam = onseam;
        this.s = s;
        this.t = t;
    }
}

@:publicFields
class MTriangle {
    var facesfront:Bool;
    var vertindex:Array<Int>;
    function new(facesfront, vertindex) {
        this.facesfront = facesfront;
        this.vertindex = vertindex;
    }
}

@:publicFields
class MTrivert {
    var v:Array<Int>;
    var lightnormalindex:Int;
    function new(v, lightnormalindex) {
        this.v = v;
        this.lightnormalindex = lightnormalindex;
    }
}

@:publicFields
class MHull {
    var clipnodes:Array<MClipNode>;
    var planes:Array<Plane>;
    var firstclipnode:Int;
    var lastclipnode:Int;
    var clip_mins:Vec;
    var clip_maxs:Vec;
    function new() {}
}

@:publicFields
class MClipNode {
    var planenum:Int;
    var children:Array<Contents>;
    function new() {}
}

@:publicFields
class MSkin {
    var group:Bool;
    var skins:Array<MSkin>;
    var interval:Float;
    var texturenum:GLTexture;
    var playertexture:Texture;
    function new(g) {
        this.group = g;
    }
}

@:publicFields
class MFrame {
    var name:String;
    var group:Bool;
    var frames:Array<MFrame>;
    var interval:Float;
    var origin:Array<Int>;
    var width:Int;
    var height:Int;
    var texturenum:Texture;
    var cmdofs:Int;
    var bboxmin:Array<Int>;
    var bboxmax:Array<Int>;
    var v:Array<MTrivert>;
    function new(g) {
        this.group = g;
    }
}

@:publicFields
class MNode {
    var contents:Contents;
    var plane:Plane;
    var num:Int;
    var parent:MNode;
    var children:Array<MNode>;
    var numfaces:Int;
    var firstface:Int;
    var visframe:Int;
    var markvisframe:Int;
    var skychain:Int;
    var waterchain:Int;
    var mins:Vec;
    var maxs:Vec;
    var cmds:Array<Array<Int>>;
    var nummarksurfaces:Int;
    var firstmarksurface:Int;
    var planenum:Int;
    function new() {}
}


@:publicFields
class MLeaf extends MNode {
    var visofs:Int;
    var ambient_level:Array<Int>;
    function new() super();
}

@:publicFields
class MTexinfo {
    var texture:Int;
    var vecs:Array<Array<Float>>;
    var flags:Int;
    function new(v,t,f) {
        vecs = v;
        texture = t;
        flags = f;
    }
}

@:publicFields
class MSurface {
    var extents:Array<Int>;
    var texturemins:Array<Int>;
    var light_s:Int;
    var light_t:Int;
    var dlightframe:Int;
    var dlightbits:Int;
    var plane:Plane;
    var texinfo:Int;
    var sky:Bool;
    var turbulent:Bool;
    var lightofs:Int;
    var styles:Array<Int>;
    var texture:Int;
    var verts:Array<Array<Float>>;
    var numedges:Int;
    var firstedge:Int;
    function new() {}
}

@:publicFields
class MTexture {
    var name:String;
    var width:Int;
    var height:Int;
    var anim_base:Int;
    var anim_frame:Int;
    var anims:Array<Int>;
    var alternate_anims:Array<Int>;
    var sky:Bool;
    var turbulent:Bool;
    var texturenum:Texture;
    function new() {}
}

@:publicFields
class MTrace {
    var allsolid:Bool;
    var startsolid:Bool;
    var inopen:Bool;
    var inwater:Bool;
    var plane:Plane;
    var fraction:Float;
    var endpos:Vec;
    var ent:Edict;
    function new() {}
}


@:publicFields
class MMoveClip {
    var type:Int;
    var trace:MTrace;
    var boxmins:Vec;
    var boxmaxs:Vec;
    var mins:Vec;
    var maxs:Vec;
    var mins2:Vec;
    var maxs2:Vec;
    var start:Vec;
    var end:Vec;
    var passedict:Edict;
    function new() {}
}


@:publicFields
class MAreaNode {
    var axis:Int;
    var dist:Float;
    var children:Array<MAreaNode>;
    var trigger_edicts:MLink;
    var solid_edicts:MLink;
    function new() {}
}

class MLink {
    public var prev:MLink;
    public var next:MLink;
    public var ent:Edict;
    public function new() {}
}

@:enum abstract EntEffect(Int) to Int {
    var no = 0;
    var brightfield = 1;
    var muzzleflash = 2;
    var brightlight = 4;
    var dimlight = 8;
}

@:enum abstract ModelEffect(Int) to Int {
    var rocket = 1;
    var grenade = 2;
    var gib = 4;
    var rotate = 8;
    var tracer = 16;
    var zomgib = 32;
    var tracer2 = 64;
    var tracer3 = 128;
}

class Mod {
    public static var novis(default,null):Array<Int>;

    static var known:Array<MModel> = [];
    static var filledcolor:Int;

    public static function Init():Void {
        novis = [];
        for (i in 0...1024)
            novis.push(0xff);

        filledcolor = 0;
        for (i in 0...256) {
            if (VID.d_8to24table[i] == 0) {
                filledcolor = i;
                break;
            }
        }
    }

    public static function PointInLeaf(p:Vec, model:MModel):MLeaf {
        if (model == null)
            Sys.Error('Mod.PointInLeaf: bad model');
        if (model.nodes == null)
            Sys.Error('Mod.PointInLeaf: bad model');
        var node = model.nodes[0];
        while (true) {
            if (node.contents < 0)
                return cast node;
            if ((Vec.DotProduct(p, node.plane.normal) - node.plane.dist) > 0)
                node = node.children[0];
            else
                node = node.children[1];
        }
    }

    static function DecompressVis(i:Int, model:MModel):Array<Int> {
        var decompressed = [];
        var out = 0;
        var row = (model.leafs.length + 7) >> 3;
        if (model.visdata == null) {
            while (row >= 0) {
                decompressed[out++] = 0xff;
                row--;
            }
            return decompressed;
        }
        var out = 0;
        while (out < row) {
            if (model.visdata[i] != 0) {
                decompressed[out++] = model.visdata[i++];
                continue;
            }
            var c = model.visdata[i + 1];
            while (c > 0) {
                decompressed[out++] = 0;
                c--;
            }
            i += 2;
        }
        return decompressed;
    }

    public static function LeafPVS(leaf:MLeaf, model:MModel):Array<Int> {
        if (leaf == model.leafs[0])
            return novis;
        return DecompressVis(leaf.visofs, model);
    }

    public static function ClearAll():Void {
        for (i in 0...known.length) {
            var mod = known[i];
            if (mod.type != brush)
                continue;
            if (mod.cmds != null)
                gl.deleteBuffer(mod.cmds);
            known[i] = new MModel(mod.name);
        }
    }

    static function FindName(name:String):MModel {
        if (name.length == 0)
            Sys.Error('Mod.FindName: NULL name');
        for (mod in known) {
            if (mod == null)
                continue;
            if (mod.name == name)
                return mod;
        }
        for (i in 0...known.length + 1) {
            if (known[i] != null)
                continue;
            return known[i] = new MModel(name);
        }
        return null;
    }

    static var loadmodel:MModel;

    static inline var IDPOLYHEADER = ('O'.code << 24) + ('P'.code << 16) + ('D'.code << 8) + 'I'.code; // little-endian "IDPO"
    static inline var IDSPRITEHEADER = ('P'.code << 24) + ('S'.code << 16) + ('D'.code << 8) + 'I'.code; // little-endian "IDSP"

    static function LoadModel(mod:MModel, crash:Bool):MModel {
        if (!mod.needload)
            return mod;
        var buf = COM.LoadFile(mod.name);
        if (buf == null) {
            if (crash)
                Sys.Error('Mod.LoadModel: ' + mod.name + ' not found');
            return null;
        }
        loadmodel = mod;
        mod.needload = false;
        var view = new DataView(buf);
        switch (view.getUint32(0, true)) {
            case IDPOLYHEADER:
                LoadAliasModel(view);
            case IDSPRITEHEADER:
                LoadSpriteModel(view);
            default:
                LoadBrushModel(view);
        }
        return mod;
    }

    public static inline function ForName(name:String, crash:Bool):MModel {
        return LoadModel(FindName(name), crash);
    }

    /*
    =====================================================

                        BRUSHMODEL LOADING

    =====================================================
    */

    static function LoadTextures(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.textures, true);
        var filelen = view.getUint32(ModelLumpOffsets.textures + 4, true);
        loadmodel.textures = [];
        var nummiptex = view.getUint32(fileofs, true);
        var dataofs = fileofs + 4;
        for (i in 0...nummiptex) {
            var miptexofs = view.getInt32(dataofs, true);
            dataofs += 4;
            if (miptexofs == -1) {
                loadmodel.textures[i] = R.notexture_mip;
                continue;
            }
            miptexofs += fileofs;
            var tx = new MTexture();
            {
                tx.name = Q.memstr(new Uint8Array(view.buffer, miptexofs, 16));
                tx.width = view.getUint32(miptexofs + 16, true);
                tx.height = view.getUint32(miptexofs + 20, true);
            }
            if (tx.name.substring(0, 3).toLowerCase() == 'sky') {
                R.InitSky(new Uint8Array(view.buffer, miptexofs + view.getUint32(miptexofs + 24, true), 32768));
                tx.texturenum = R.solidskytexture;
                R.skytexturenum = i;
                tx.sky = true;
            }
            else
            {
                var glt = GL.LoadTexture(tx.name, tx.width, tx.height, new Uint8Array(view.buffer, miptexofs + view.getUint32(miptexofs + 24, true), tx.width * tx.height));
                tx.texturenum = glt.texnum;
                if (tx.name.charCodeAt(0) == 42)
                    tx.turbulent = true;
            }
            loadmodel.textures[i] = tx;
        }

        for (i in 0...nummiptex) {
            var tx = loadmodel.textures[i];
            if (tx.name.charCodeAt(0) != 43)
                continue;
            if (tx.name.charCodeAt(1) != 48)
                continue;
            var name = tx.name.substring(2);
            tx.anims = [i];
            tx.alternate_anims = [];
            for (j in 0...nummiptex) {
                var tx2 = loadmodel.textures[j];
                if (tx2.name.charCodeAt(0) != 43)
                    continue;
                if (tx2.name.substring(2) != name)
                    continue;
                var num = tx2.name.charCodeAt(1);
                if (num == 48)
                    continue;
                if ((num >= 49) && (num <= 57)) {
                    tx.anims[num - 48] = j;
                    tx2.anim_base = i;
                    tx2.anim_frame = num - 48;
                    continue;
                }
                if (num >= 97)
                    num -= 32;
                if ((num >= 65) && (num <= 74)) {
                    tx.alternate_anims[num - 65] = j;
                    tx2.anim_base = i;
                    tx2.anim_frame = num - 65;
                    continue;
                }
                Sys.Error('Bad animating texture ' + tx.name);
            }
            for (j in 0...tx.anims.length) {
                if (tx.anims[j] == null)
                    Sys.Error('Missing frame ' + j + ' of ' + tx.name);
            }
            for (j in 0...tx.alternate_anims.length) {
                if (tx.alternate_anims[j] == null)
                    Sys.Error('Missing frame ' + j + ' of ' + tx.name);
            }
            loadmodel.textures[i] = tx;
        }

        loadmodel.textures[loadmodel.textures.length] = R.notexture_mip;
    }

    static function LoadLighting(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.lighting, true);
        var filelen = view.getUint32(ModelLumpOffsets.lighting + 4, true);
        if (filelen == 0)
            return;
        loadmodel.lightdata = new Uint8Array(view.buffer.slice(fileofs, fileofs + filelen));
    }

    static function LoadVisibility(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.visibility, true);
        var filelen = view.getUint32(ModelLumpOffsets.visibility + 4, true);
        if (filelen == 0)
            return;
        loadmodel.visdata = new Uint8Array(view.buffer.slice(fileofs, fileofs + filelen));
    }

    static function LoadEntities(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.entities, true);
        var filelen = view.getUint32(ModelLumpOffsets.entities + 4, true);
        loadmodel.entities = Q.memstr(new Uint8Array(view.buffer, fileofs, filelen));
    }

    static function LoadVertexes(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.vertexes, true);
        var filelen = view.getUint32(ModelLumpOffsets.vertexes + 4, true);
        if ((filelen % 12) != 0)
            Sys.Error('Mod.LoadVisibility: funny lump size in ' + loadmodel.name);
        var count = Std.int(filelen / 12);
        loadmodel.vertexes = [];
        for (i in 0...count) {
            loadmodel.vertexes[i] = Vec.of(view.getFloat32(fileofs, true), view.getFloat32(fileofs + 4, true), view.getFloat32(fileofs + 8, true));
            fileofs += 12;
        }
    }

    static function LoadSubmodels(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.models, true);
        var filelen = view.getUint32(ModelLumpOffsets.models + 4, true);
        var count = filelen >> 6;
        if (count == 0)
            Sys.Error('Mod.LoadSubmodels: funny lump size in ' + loadmodel.name);
        loadmodel.submodels = [];

        loadmodel.mins = Vec.of(view.getFloat32(fileofs, true) - 1.0,
            view.getFloat32(fileofs + 4, true) - 1.0,
            view.getFloat32(fileofs + 8, true) - 1.0);
        loadmodel.maxs = Vec.of(view.getFloat32(fileofs + 12, true) + 1.0,
            view.getFloat32(fileofs + 16, true) + 1.0,
            view.getFloat32(fileofs + 20, true) + 1.0);
        loadmodel.hulls[0].firstclipnode = view.getUint32(fileofs + 36, true);
        loadmodel.hulls[1].firstclipnode = view.getUint32(fileofs + 40, true);
        loadmodel.hulls[2].firstclipnode = view.getUint32(fileofs + 44, true);
        fileofs += 64;

        var clipnodes = loadmodel.hulls[0].clipnodes;
        for (i in 1...count) {
            var out = Mod.FindName('*' + i);
            out.needload = false;
            out.type = brush;
            out.submodel = true;
            out.mins = Vec.of(view.getFloat32(fileofs, true) - 1.0,
                view.getFloat32(fileofs + 4, true) - 1.0,
                view.getFloat32(fileofs + 8, true) - 1.0);
            out.maxs = Vec.of(view.getFloat32(fileofs + 12, true) + 1.0,
                view.getFloat32(fileofs + 16, true) + 1.0,
                view.getFloat32(fileofs + 20, true) + 1.0);
            out.origin = Vec.of(view.getFloat32(fileofs + 24, true), view.getFloat32(fileofs + 28, true), view.getFloat32(fileofs + 32, true));
            out.hulls = [
                {
                    var h = new MHull();
                    h.clipnodes = clipnodes;
                    h.firstclipnode = view.getUint32(fileofs + 36, true);
                    h.lastclipnode = loadmodel.nodes.length - 1;
                    h.planes = loadmodel.planes;
                    h.clip_mins = new Vec();
                    h.clip_maxs = new Vec();
                    h;
                },
                {
                    var h = new MHull();
                    h.clipnodes = loadmodel.clipnodes;
                    h.firstclipnode = view.getUint32(fileofs + 40, true);
                    h.lastclipnode = loadmodel.clipnodes.length - 1;
                    h.planes = loadmodel.planes;
                    h.clip_mins = Vec.of(-16.0, -16.0, -24.0);
                    h.clip_maxs = Vec.of(16.0, 16.0, 32.0);
                    h;
                },
                {
                    var h = new MHull();
                    h.clipnodes = loadmodel.clipnodes;
                    h.firstclipnode = view.getUint32(fileofs + 44, true);
                    h.lastclipnode = loadmodel.clipnodes.length - 1;
                    h.planes = loadmodel.planes;
                    h.clip_mins = Vec.of(-32.0, -32.0, -24.0);
                    h.clip_maxs = Vec.of(32.0, 32.0, 64.0);
                    h;
                }
            ];
            out.textures = loadmodel.textures;
            out.lightdata = loadmodel.lightdata;
            out.faces = loadmodel.faces;
            out.firstface = view.getUint32(fileofs + 56, true);
            out.numfaces = view.getUint32(fileofs + 60, true);
            loadmodel.submodels[i - 1] = out;
            fileofs += 64;
        }
    }

    static function LoadEdges(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.edges, true);
        var filelen = view.getUint32(ModelLumpOffsets.edges + 4, true);
        if ((filelen & 3) != 0)
            Sys.Error('Mod.LoadEdges: funny lump size in ' + loadmodel.name);
        var count = filelen >> 2;
        loadmodel.edges = [];
        for (i in 0...count) {
            loadmodel.edges[i] = [view.getUint16(fileofs, true), view.getUint16(fileofs + 2, true)];
            fileofs += 4;
        }
    }

    static function LoadTexinfo(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.texinfo, true);
        var filelen = view.getUint32(ModelLumpOffsets.texinfo + 4, true);
        if ((filelen % 40) != 0)
            Sys.Error('Mod.LoadTexinfo: funny lump size in ' + loadmodel.name);
        var count = Std.int(filelen / 40);
        loadmodel.texinfo = [];
        for (i in 0...count) {
            var out = new MTexinfo(
                [
                    [view.getFloat32(fileofs, true), view.getFloat32(fileofs + 4, true), view.getFloat32(fileofs + 8, true), view.getFloat32(fileofs + 12, true)],
                    [view.getFloat32(fileofs + 16, true), view.getFloat32(fileofs + 20, true), view.getFloat32(fileofs + 24, true), view.getFloat32(fileofs + 28, true)]
                ],
                view.getUint32(fileofs + 32, true),
                view.getUint32(fileofs + 36, true)
            );
            if (out.texture >= loadmodel.textures.length) {
                out.texture = loadmodel.textures.length - 1;
                out.flags = 0;
            }
            loadmodel.texinfo[i] = out;
            fileofs += 40;
        }
    }

    static function LoadFaces(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.faces, true);
        var filelen = view.getUint32(ModelLumpOffsets.faces + 4, true);
        if ((filelen % 20) != 0)
            Sys.Error('Mod.LoadFaces: funny lump size in ' + loadmodel.name);
        var count = Std.int(filelen / 20);
        loadmodel.firstface = 0;
        loadmodel.numfaces = count;
        loadmodel.faces = [];
        for (i in 0...count) {
            var styles = new Uint8Array(view.buffer, fileofs + 12, 4);
            var out = new MSurface();
            {
                out.plane = loadmodel.planes[view.getUint16(fileofs, true)];
                out.firstedge = view.getUint16(fileofs + 4, true);
                out.numedges = view.getUint16(fileofs + 8, true);
                out.texinfo = view.getUint16(fileofs + 10, true);
                out.styles = [];
                out.lightofs = view.getInt32(fileofs + 16, true);
            };
            if (styles[0] != 255)
                out.styles[0] = styles[0];
            if (styles[1] != 255)
                out.styles[1] = styles[1];
            if (styles[2] != 255)
                out.styles[2] = styles[2];
            if (styles[3] != 255)
                out.styles[3] = styles[3];

            var mins = [999999.0, 999999.0];
            var maxs = [-99999.0, -99999.0];
            var tex = loadmodel.texinfo[out.texinfo];
            out.texture = tex.texture;
            for (j in 0...out.numedges) {
                var e = loadmodel.surfedges[out.firstedge + j];
                var v;
                if (e >= 0)
                    v = loadmodel.vertexes[loadmodel.edges[e][0]];
                else
                    v = loadmodel.vertexes[loadmodel.edges[-e][1]];

                var val = Vec.DotProduct(v, Vec.ofArray(tex.vecs[0])) + tex.vecs[0][3];
                if (val < mins[0])
                    mins[0] = val;
                if (val > maxs[0])
                    maxs[0] = val;
                val = Vec.DotProduct(v, Vec.ofArray(tex.vecs[1])) + tex.vecs[1][3];
                if (val < mins[1])
                    mins[1] = val;
                if (val > maxs[1])
                    maxs[1] = val;
            }
            out.texturemins = [Math.floor(mins[0] / 16) * 16, Math.floor(mins[1] / 16) * 16];
            out.extents = [Math.ceil(maxs[0] / 16) * 16 - out.texturemins[0], Math.ceil(maxs[1] / 16) * 16 - out.texturemins[1]];

            if (loadmodel.textures[tex.texture].turbulent)
                out.turbulent = true;
            else if (loadmodel.textures[tex.texture].sky)
                out.sky = true;

            loadmodel.faces[i] = out;
            fileofs += 20;
        }
    }

    static function SetParent(node:MNode, parent:MNode) {
        node.parent = parent;
        if (node.contents < 0)
            return;
        Mod.SetParent(node.children[0], node);
        Mod.SetParent(node.children[1], node);
    }

    static function LoadNodes(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.nodes, true);
        var filelen = view.getUint32(ModelLumpOffsets.nodes + 4, true);
        if ((filelen == 0) || ((filelen % 24) != 0))
            Sys.Error('Mod.LoadNodes: funny lump size in ' + loadmodel.name);
        var count = Std.int(filelen / 24);
        loadmodel.nodes = [];
        var children = new haxe.ds.Vector(count);
        for (i in 0...count) {
            var n = loadmodel.nodes[i] = new MNode();
            n.num = i;
            n.contents = 0;
            n.planenum = view.getUint32(fileofs, true);
            children[i] = [view.getInt16(fileofs + 4, true), view.getInt16(fileofs + 6, true)];
            n.mins = Vec.of(view.getInt16(fileofs + 8, true), view.getInt16(fileofs + 10, true), view.getInt16(fileofs + 12, true));
            n.maxs = Vec.of(view.getInt16(fileofs + 14, true), view.getInt16(fileofs + 16, true), view.getInt16(fileofs + 18, true));
            n.firstface = view.getUint16(fileofs + 20, true);
            n.numfaces = view.getUint16(fileofs + 22, true);
            n.cmds = [];
            fileofs += 24;
        }
        for (i in 0...count) {
            var out = loadmodel.nodes[i];
            out.plane = loadmodel.planes[out.planenum];
            out.children = [];
            var children = children[i];
            if (children[0] >= 0)
                out.children[0] = loadmodel.nodes[children[0]];
            else
                out.children[0] = loadmodel.leafs[-1 - children[0]];
            if (children[1] >= 0)
                out.children[1] = loadmodel.nodes[children[1]];
            else
                out.children[1] = loadmodel.leafs[-1 - children[1]];
        }
        Mod.SetParent(loadmodel.nodes[0], null);
    }

    static function LoadLeafs(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.leafs, true);
        var filelen = view.getUint32(ModelLumpOffsets.leafs + 4, true);
        if ((filelen % 28) != 0)
            Sys.Error('Mod.LoadLeafs: funny lump size in ' + loadmodel.name);
        var count = Std.int(filelen / 28);
        loadmodel.leafs = [];
        for (i in 0...count) {
            var out = new MLeaf();
            {
                out.num = i;
                out.contents = view.getInt32(fileofs, true);
                out.visofs = view.getInt32(fileofs + 4, true);
                out.mins = Vec.of(view.getInt16(fileofs + 8, true), view.getInt16(fileofs + 10, true), view.getInt16(fileofs + 12, true));
                out.maxs = Vec.of(view.getInt16(fileofs + 14, true), view.getInt16(fileofs + 16, true), view.getInt16(fileofs + 18, true));
                out.firstmarksurface = view.getUint16(fileofs + 20, true);
                out.nummarksurfaces = view.getUint16(fileofs + 22, true);
                out.ambient_level = [view.getUint8(fileofs + 24), view.getUint8(fileofs + 25), view.getUint8(fileofs + 26), view.getUint8(fileofs + 27)];
                out.cmds = [];
                out.skychain = 0;
                out.waterchain = 0;
            };
            loadmodel.leafs[i] = out;
            fileofs += 28;
        };
    }

    static function LoadClipnodes(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.clipnodes, true);
        var filelen = view.getUint32(ModelLumpOffsets.clipnodes + 4, true);
        var count = filelen >> 3;
        loadmodel.clipnodes = [];

        loadmodel.hulls = [];
        loadmodel.hulls[1] = {
            var h = new MHull();
            h.clipnodes = loadmodel.clipnodes;
            h.firstclipnode = 0;
            h.lastclipnode = count - 1;
            h.planes = loadmodel.planes;
            h.clip_mins = Vec.of(-16.0, -16.0, -24.0);
            h.clip_maxs = Vec.of(16.0, 16.0, 32.0);
            h;
        };
        loadmodel.hulls[2] = {
            var h = new MHull();
            h.clipnodes = loadmodel.clipnodes;
            h.firstclipnode = 0;
            h.lastclipnode = count - 1;
            h.planes = loadmodel.planes;
            h.clip_mins = Vec.of(-32.0, -32.0, -24.0);
            h.clip_maxs = Vec.of(32.0, 32.0, 64.0);
            h;
        };
        for (i in 0...count) {
            loadmodel.clipnodes[i] = {
                var n = new MClipNode();
                n.planenum = view.getUint32(fileofs, true);
                n.children = [view.getInt16(fileofs + 4, true), view.getInt16(fileofs + 6, true)];
                n;
            };
            fileofs += 8;
        }
    }

    static function MakeHull0() {
        var clipnodes = [];
        var hull = {
            var h = new MHull();
            h.clipnodes = clipnodes;
            h.lastclipnode = loadmodel.nodes.length - 1;
            h.planes = loadmodel.planes;
            h.clip_mins = new Vec();
            h.clip_maxs = new Vec();
            h;
        };
        for (i in 0...loadmodel.nodes.length) {
            var node = loadmodel.nodes[i];
            var out = new MClipNode();
            out.planenum = node.planenum;
            out.children = [];
            var child = node.children[0];
            out.children[0] = child.contents < 0 ? child.contents : child.num;
            child = node.children[1];
            out.children[1] = child.contents < 0 ? child.contents : child.num;
            clipnodes[i] = out;
        }
        loadmodel.hulls[0] = hull;
    }

    static function LoadMarksurfaces(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.marksurfaces, true);
        var filelen = view.getUint32(ModelLumpOffsets.marksurfaces + 4, true);
        var count = filelen >> 1;
        loadmodel.marksurfaces = [];
        for (i in 0...count) {
            var j = view.getUint16(fileofs + (i << 1), true);
            if (j > loadmodel.faces.length)
                Sys.Error('Mod.LoadMarksurfaces: bad surface number');
            loadmodel.marksurfaces[i] = j;
        }
    }

    static function LoadSurfedges(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.surfedges, true);
        var filelen = view.getUint32(ModelLumpOffsets.surfedges + 4, true);
        var count = filelen >> 2;
        loadmodel.surfedges = [];
        for (i in 0...count)
            loadmodel.surfedges[i] = view.getInt32(fileofs + (i << 2), true);
    }

    static function LoadPlanes(view:DataView):Void {
        var fileofs = view.getUint32(ModelLumpOffsets.planes, true);
        var filelen = view.getUint32(ModelLumpOffsets.planes + 4, true);
        if ((filelen % 20) != 0)
            Sys.Error('Mod.LoadPlanes: funny lump size in ' + loadmodel.name);
        var count = Std.int(filelen / 20);
        loadmodel.planes = [];
        for (i in 0...count) {
            var out = new Plane();
            out.normal = Vec.of(view.getFloat32(fileofs, true), view.getFloat32(fileofs + 4, true), view.getFloat32(fileofs + 8, true));
            out.dist = view.getFloat32(fileofs + 12, true);
            out.type = view.getUint32(fileofs + 16, true);
            out.signbits = 0;
            if (out.normal[0] < 0)
                ++out.signbits;
            if (out.normal[1] < 0)
                out.signbits += 2;
            if (out.normal[2] < 0)
                out.signbits += 4;
            loadmodel.planes[i] = out;
            fileofs += 20;
        }
    }

    static function LoadBrushModel(data:DataView):Void {
        var version = data.getUint32(0, true);
        if (version != ModelVersion.brush)
            Sys.Error('Mod.LoadBrushModel: ' + loadmodel.name + ' has wrong version number (' + version + ' should be ' + ModelVersion.brush + ')');

        loadmodel.type = brush;

        LoadVertexes(data);
        LoadEdges(data);
        LoadSurfedges(data);
        LoadTextures(data);
        LoadLighting(data);
        LoadPlanes(data);
        LoadTexinfo(data);
        LoadFaces(data);
        LoadMarksurfaces(data);
        LoadVisibility(data);
        LoadLeafs(data);
        LoadNodes(data);
        LoadClipnodes(data);
        MakeHull0();
        LoadEntities(data);
        LoadSubmodels(data);

        var mins = [0.0, 0.0, 0.0];
        var maxs = [0.0, 0.0, 0.0];

        for (vert in loadmodel.vertexes) {
            if (vert[0] < mins[0])
                mins[0] = vert[0];
            else if (vert[0] > maxs[0])
                maxs[0] = vert[0];

            if (vert[1] < mins[1])
                mins[1] = vert[1];
            else if (vert[1] > maxs[1])
                maxs[1] = vert[1];

            if (vert[2] < mins[2])
                mins[2] = vert[2];
            else if (vert[2] > maxs[2])
                maxs[2] = vert[2];
        }

        loadmodel.radius = Vec.Length(Vec.of(
            Math.max(Math.abs(mins[0]), Math.abs(maxs[0])),
            Math.max(Math.abs(mins[1]), Math.abs(maxs[1])),
            Math.max(Math.abs(mins[2]), Math.abs(maxs[2]))
        ));
    }

    /*
    ====================================================

    ALIAS MODELS

    ====================================================
    */

    static function TranslatePlayerSkin(data:Uint8Array, skin:MSkin):Void {
        if (loadmodel.skinwidth != 512 || loadmodel.skinheight != 256)
            data = GL.ResampleTexture(data, loadmodel.skinwidth, loadmodel.skinheight, 512, 256);
        var out = new Uint8Array(new ArrayBuffer(512 * 256 * 4));
        for (i in 0...(512 * 256)) {
            var original = data[i];
            if ((original >> 4) == 1) {
                out[i << 2] = (original & 15) * 17;
                out[(i << 2) + 1] = 255;
            } else if ((original >> 4) == 6) {
                out[(i << 2) + 2] = (original & 15) * 17;
                out[(i << 2) + 3] = 255;
            }
        }
        skin.playertexture = gl.createTexture();
        GL.Bind(0, skin.playertexture);
        gl.texImage2D(RenderingContext.TEXTURE_2D, 0, RenderingContext.RGBA, 512, 256, 0, RenderingContext.RGBA, RenderingContext.UNSIGNED_BYTE, out);
        gl.generateMipmap(RenderingContext.TEXTURE_2D);
        gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MIN_FILTER, GL.filter_min);
        gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MAG_FILTER, GL.filter_max);
    }

    static function FloodFillSkin(skin:Uint8Array) {
        var fillcolor = skin[0];
        if (fillcolor == Mod.filledcolor)
            return;

        var width = loadmodel.skinwidth;
        var height = loadmodel.skinheight;

        var lifo = [[0, 0]];
        var sp = 1;
        while (sp > 0) {
            var cur = lifo[--sp];
            var x = cur[0];
            var y = cur[1];
            skin[y * width + x] = Mod.filledcolor;
            if (x > 0) {
                if (skin[y * width + x - 1] == fillcolor)
                    lifo[sp++] = [x - 1, y];
            }
            if (x < (width - 1)) {
                if (skin[y * width + x + 1] == fillcolor)
                    lifo[sp++] = [x + 1, y];
            }
            if (y > 0) {
                if (skin[(y - 1) * width + x] == fillcolor)
                    lifo[sp++] = [x, y - 1];
            }
            if (y < (height - 1)) {
                if (skin[(y + 1) * width + x] == fillcolor)
                    lifo[sp++] = [x, y + 1];
            }
        }
    }

    static function LoadAllSkins(model:DataView, inmodel:Int):Int {
        loadmodel.skins = [];
        var skinsize = loadmodel.skinwidth * loadmodel.skinheight;
        for (i in 0...loadmodel.numskins) {
            inmodel += 4;
            if (model.getUint32(inmodel - 4, true) == 0) {
                var skin = new Uint8Array(model.buffer, inmodel, skinsize);
                Mod.FloodFillSkin(skin);
                var g = new MSkin(false);
                g.texturenum = GL.LoadTexture(loadmodel.name + '_' + i,
                        loadmodel.skinwidth,
                        loadmodel.skinheight,
                        skin);
                loadmodel.skins[i] = g;
                if (loadmodel.player)
                    TranslatePlayerSkin(new Uint8Array(model.buffer, inmodel, skinsize), loadmodel.skins[i]);
                inmodel += skinsize;
            }
            else
            {
                var group = new MSkin(true);
                var numskins = model.getUint32(inmodel, true);
                inmodel += 4;
                for (j in 0...numskins) {
                    var s = new MSkin(false);
                    s.interval = model.getFloat32(inmodel, true);
                    if (s.interval <= 0.0)
                        Sys.Error('Mod.LoadAllSkins: interval<=0');
                    group.skins[j] = s;
                    inmodel += 4;
                }
                for (j in 0...numskins) {
                    var skin = new Uint8Array(model.buffer, inmodel, skinsize);
                    Mod.FloodFillSkin(skin);
                    group.skins[j].texturenum = GL.LoadTexture(loadmodel.name + '_' + i + '_' + j,
                        loadmodel.skinwidth,
                        loadmodel.skinheight,
                        skin);
                    if (loadmodel.player)
                        Mod.TranslatePlayerSkin(new Uint8Array(model.buffer, inmodel, skinsize), group.skins[j]);
                    inmodel += skinsize;
                }
                loadmodel.skins[i] = group;
            }
        }
        return inmodel;
    }

    static function LoadAllFrames(model:DataView, inmodel:Int):Void {
        loadmodel.frames = [];
        for (i in 0...loadmodel.numframes) {
            inmodel += 4;
            if (model.getUint32(inmodel - 4, true) == 0) {
                var frame = new MFrame(false);
                frame.group = false;
                frame.bboxmin = [model.getUint8(inmodel), model.getUint8(inmodel + 1), model.getUint8(inmodel + 2)];
                frame.bboxmax = [model.getUint8(inmodel + 4), model.getUint8(inmodel + 5), model.getUint8(inmodel + 6)];
                frame.name = Q.memstr(new Uint8Array(model.buffer, inmodel + 8, 16));
                frame.v = [];
                inmodel += 24;
                for (j in 0...loadmodel.numverts) {
                    frame.v[j] = new MTrivert(
                        [model.getUint8(inmodel), model.getUint8(inmodel + 1), model.getUint8(inmodel + 2)],
                        model.getUint8(inmodel + 3)
                    );
                    inmodel += 4;
                }
                loadmodel.frames[i] = frame;
            }
            else
            {
                var group = new MFrame(true);
                group.bboxmin = [model.getUint8(inmodel + 4), model.getUint8(inmodel + 5), model.getUint8(inmodel + 6)];
                group.bboxmax = [model.getUint8(inmodel + 8), model.getUint8(inmodel + 9), model.getUint8(inmodel + 10)];
                group.frames = [];
                var numframes = model.getUint32(inmodel, true);
                inmodel += 12;
                for (j in 0...numframes) {
                    var f = new MFrame(false);
                    f.interval = model.getFloat32(inmodel, true);
                    group.frames[j] = f;
                    if (group.frames[j].interval <= 0.0)
                        Sys.Error('Mod.LoadAllFrames: interval<=0');
                    inmodel += 4;
                }
                for (j in 0...numframes) {
                    var frame = group.frames[j];
                    frame.bboxmin = [model.getUint8(inmodel), model.getUint8(inmodel + 1), model.getUint8(inmodel + 2)];
                    frame.bboxmax = [model.getUint8(inmodel + 4), model.getUint8(inmodel + 5), model.getUint8(inmodel + 6)];
                    frame.name = Q.memstr(new Uint8Array(model.buffer, inmodel + 8, 16));
                    frame.v = [];
                    inmodel += 24;
                    for (k in 0...loadmodel.numverts) {
                        frame.v[k] = new MTrivert(
                            [model.getUint8(inmodel), model.getUint8(inmodel + 1), model.getUint8(inmodel + 2)],
                            model.getUint8(inmodel + 3)
                        );
                        inmodel += 4;
                    }
                }
                loadmodel.frames[i] = group;
            }
        }
    }

    static function LoadAliasModel(model:DataView):Void {
        var version = model.getUint32(4, true);
        if (version != ModelVersion.alias)
            Sys.Error(loadmodel.name + ' has wrong version number (' + version + ' should be ' + ModelVersion.alias + ')');

        loadmodel.type = alias;
        loadmodel.player = loadmodel.name == 'progs/player.mdl';
        loadmodel.scale = Vec.of(model.getFloat32(8, true), model.getFloat32(12, true), model.getFloat32(16, true));
        loadmodel.scale_origin = Vec.of(model.getFloat32(20, true), model.getFloat32(24, true), model.getFloat32(28, true));
        loadmodel.boundingradius = model.getFloat32(32, true);
        loadmodel.numskins = model.getUint32(48, true);
        if (loadmodel.numskins == 0)
            Sys.Error('model ' + loadmodel.name + ' has no skins');
        loadmodel.skinwidth = model.getUint32(52, true);
        loadmodel.skinheight = model.getUint32(56, true);
        loadmodel.numverts = model.getUint32(60, true);
        if (loadmodel.numverts == 0)
            Sys.Error('model ' + loadmodel.name + ' has no vertices');
        loadmodel.numtris = model.getUint32(64, true);
        if (loadmodel.numtris == 0)
            Sys.Error('model ' + loadmodel.name + ' has no triangles');
        loadmodel.numframes = model.getUint32(68, true);
        if (loadmodel.numframes == 0)
            Sys.Error('model ' + loadmodel.name + ' has no frames');
        loadmodel.random = model.getUint32(72, true) == 1;
        loadmodel.flags = cast model.getUint32(76, true);
        loadmodel.mins = Vec.of(-16.0, -16.0, -16.0);
        loadmodel.maxs = Vec.of(16.0, 16.0, 16.0);

        var inmodel = Mod.LoadAllSkins(model, 84);

        loadmodel.stverts = [];
        for (i in 0...loadmodel.numverts) {
            loadmodel.stverts[i] = new MSTVert(
                model.getUint32(inmodel, true) != 0,
                model.getUint32(inmodel + 4, true),
                model.getUint32(inmodel + 8, true)
            );
            inmodel += 12;
        }

        loadmodel.triangles = [];
        for (i in 0...loadmodel.numtris) {
            loadmodel.triangles[i] = new MTriangle(
                model.getUint32(inmodel, true) != 0,
                [
                    model.getUint32(inmodel + 4, true),
                    model.getUint32(inmodel + 8, true),
                    model.getUint32(inmodel + 12, true)
                ]
            );
            inmodel += 16;
        }

        Mod.LoadAllFrames(model, inmodel);

        var cmds = [];

        for (i in 0...loadmodel.numtris) {
            var triangle = loadmodel.triangles[i];
            if (triangle.facesfront) {
                var vert = loadmodel.stverts[triangle.vertindex[0]];
                cmds[cmds.length] = (vert.s + 0.5) / loadmodel.skinwidth;
                cmds[cmds.length] = (vert.t + 0.5) / loadmodel.skinheight;
                vert = loadmodel.stverts[triangle.vertindex[1]];
                cmds[cmds.length] = (vert.s + 0.5) / loadmodel.skinwidth;
                cmds[cmds.length] = (vert.t + 0.5) / loadmodel.skinheight;
                vert = loadmodel.stverts[triangle.vertindex[2]];
                cmds[cmds.length] = (vert.s + 0.5) / loadmodel.skinwidth;
                cmds[cmds.length] = (vert.t + 0.5) / loadmodel.skinheight;
                continue;
            }
            for (j in 0...3) {
                var vert = loadmodel.stverts[triangle.vertindex[j]];
                if (vert.onseam)
                    cmds[cmds.length] = (vert.s + loadmodel.skinwidth / 2 + 0.5) / loadmodel.skinwidth;
                else
                    cmds[cmds.length] = (vert.s + 0.5) / loadmodel.skinwidth;
                cmds[cmds.length] = (vert.t + 0.5) / loadmodel.skinheight;
            }
        }

        var group, frame;
        for (i in 0...loadmodel.numframes) {
            group = loadmodel.frames[i];
            if (group.group) {
                for (j in 0...group.frames.length) {
                    frame = group.frames[j];
                    frame.cmdofs = cmds.length << 2;
                    for (k in 0...loadmodel.numtris) {
                        var triangle = loadmodel.triangles[k];
                        for (l in 0...3) {
                            var vert = frame.v[triangle.vertindex[l]];
                            if (vert.lightnormalindex >= 162)
                                Sys.Error('lightnormalindex >= NUMVERTEXNORMALS');
                            cmds[cmds.length] = vert.v[0] * loadmodel.scale[0] + loadmodel.scale_origin[0];
                            cmds[cmds.length] = vert.v[1] * loadmodel.scale[1] + loadmodel.scale_origin[1];
                            cmds[cmds.length] = vert.v[2] * loadmodel.scale[2] + loadmodel.scale_origin[2];
                            cmds[cmds.length] = R.avertexnormals[vert.lightnormalindex * 3];
                            cmds[cmds.length] = R.avertexnormals[vert.lightnormalindex * 3 + 1];
                            cmds[cmds.length] = R.avertexnormals[vert.lightnormalindex * 3 + 2];
                        }
                    }
                }
                continue;
            }
            frame = group;
            frame.cmdofs = cmds.length << 2;
            for (j in 0...loadmodel.numtris) {
                var triangle = loadmodel.triangles[j];
                for (k in 0...3) {
                    var vert = frame.v[triangle.vertindex[k]];
                    if (vert.lightnormalindex >= 162)
                        Sys.Error('lightnormalindex >= NUMVERTEXNORMALS');
                    cmds[cmds.length] = vert.v[0] * loadmodel.scale[0] + loadmodel.scale_origin[0];
                    cmds[cmds.length] = vert.v[1] * loadmodel.scale[1] + loadmodel.scale_origin[1];
                    cmds[cmds.length] = vert.v[2] * loadmodel.scale[2] + loadmodel.scale_origin[2];
                    cmds[cmds.length] = R.avertexnormals[vert.lightnormalindex * 3];
                    cmds[cmds.length] = R.avertexnormals[vert.lightnormalindex * 3 + 1];
                    cmds[cmds.length] = R.avertexnormals[vert.lightnormalindex * 3 + 2];
                }
            }
        }

        loadmodel.cmds = gl.createBuffer();
        gl.bindBuffer(RenderingContext.ARRAY_BUFFER, loadmodel.cmds);
        gl.bufferData(RenderingContext.ARRAY_BUFFER, new Float32Array(cmds), RenderingContext.STATIC_DRAW);
    }

    static function LoadSpriteFrame(identifier:String, model:DataView, inframe:Int, frame:MFrame):Int {
        frame.origin = [model.getInt32(inframe, true), -model.getInt32(inframe + 4, true)];
        frame.width = model.getUint32(inframe + 8, true);
        frame.height = model.getUint32(inframe + 12, true);
        var size = frame.width * frame.height;

        for (glt in GL.textures) {
            if (glt.identifier == identifier) {
                if ((frame.width != glt.width) || (frame.height != glt.height))
                    Sys.Error('Mod.LoadSpriteFrame: cache mismatch');
                frame.texturenum = glt.texnum;
                return inframe + 16 + frame.width * frame.height;
            }
        }

        var data = new Uint8Array(model.buffer, inframe + 16, size);
        var scaled_width = frame.width, scaled_height = frame.height;
        if (((frame.width & (frame.width - 1)) != 0) || ((frame.height & (frame.height - 1)) != 0)) {
            --scaled_width;
            scaled_width |= (scaled_width >> 1);
            scaled_width |= (scaled_width >> 2);
            scaled_width |= (scaled_width >> 4);
            scaled_width |= (scaled_width >> 8);
            scaled_width |= (scaled_width >> 16);
            ++scaled_width;
            --scaled_height;
            scaled_height |= (scaled_height >> 1);
            scaled_height |= (scaled_height >> 2);
            scaled_height |= (scaled_height >> 4);
            scaled_height |= (scaled_height >> 8);
            scaled_height |= (scaled_height >> 16);
            ++scaled_height;
        }
        if (scaled_width > GL.maxtexturesize)
            scaled_width = GL.maxtexturesize;
        if (scaled_height > GL.maxtexturesize)
            scaled_height = GL.maxtexturesize;
        if ((scaled_width != frame.width) || (scaled_height != frame.height)) {
            size = scaled_width * scaled_height;
            data = GL.ResampleTexture(data, frame.width, frame.height, scaled_width, scaled_height);
        }

        var trans = new ArrayBuffer(size << 2);
        var trans32 = new Uint32Array(trans);
        for (i in 0...size) {
            if (data[i] != 255)
                trans32[i] = COM.LittleLong(VID.d_8to24table[data[i]] + 0xff000000);
        }

        var glt = new GLTexture(identifier, frame.width, frame.height);
        GL.Bind(0, glt.texnum);
        gl.texImage2D(RenderingContext.TEXTURE_2D, 0, RenderingContext.RGBA, scaled_width, scaled_height, 0, RenderingContext.RGBA, RenderingContext.UNSIGNED_BYTE, new Uint8Array(trans));
        gl.generateMipmap(RenderingContext.TEXTURE_2D);
        gl.texParameterf(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MIN_FILTER, GL.filter_min);
        gl.texParameterf(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MAG_FILTER, GL.filter_max);
        GL.textures[GL.textures.length] = glt;
        frame.texturenum = glt.texnum;
        return inframe + 16 + frame.width * frame.height;
    }

    static function LoadSpriteModel(model:DataView):Void {
        var version = model.getUint32(4, true);
        if (version != ModelVersion.sprite)
            Sys.Error(loadmodel.name + ' has wrong version number (' + version + ' should be ' + ModelVersion.sprite + ')');

        loadmodel.type = sprite;
        loadmodel.oriented = model.getUint32(8, true) == 3;
        loadmodel.boundingradius = model.getFloat32(12, true);
        loadmodel.width = model.getUint32(16, true);
        loadmodel.height = model.getUint32(20, true);
        loadmodel.numframes = model.getUint32(24, true);
        if (loadmodel.numframes == 0)
            Sys.Error('model ' + loadmodel.name + ' has no frames');
        loadmodel.random = model.getUint32(32, true) == 1;
        loadmodel.mins = Vec.of(loadmodel.width * -0.5, loadmodel.width * -0.5, loadmodel.height * -0.5);
        loadmodel.maxs = Vec.of(loadmodel.width * 0.5, loadmodel.width * 0.5, loadmodel.height * 0.5);

        loadmodel.frames = [];
        var inframe = 36, frame, group, numframes;
        for (i in 0...loadmodel.numframes) {
            inframe += 4;
            if (model.getUint32(inframe - 4, true) == 0) {
                frame = new MFrame(false);
                loadmodel.frames[i] = frame;
                inframe = Mod.LoadSpriteFrame(loadmodel.name + '_' + i, model, inframe, frame);
            }
            else
            {
                group = new MFrame(true);
                group.frames = [];
                loadmodel.frames[i] = group;
                numframes = model.getUint32(inframe, true);
                inframe += 4;
                for (j in 0...numframes) {
                    var f  = new MFrame(false);
                    f.interval = model.getFloat32(inframe, true);
                    group.frames[j] = f;
                    if (group.frames[j].interval <= 0.0)
                        Sys.Error('Mod.LoadSpriteModel: interval<=0');
                    inframe += 4;
                }
                for (j in 0...numframes)
                    inframe = Mod.LoadSpriteFrame(loadmodel.name + '_' + i + '_' + j, model, inframe, group.frames[j]);
            }
        }
    }

    public static function Print() {
        Console.Print('Cached models:\n');
        for (mod in known)
            Console.Print(mod.name + '\n');
    }
}
