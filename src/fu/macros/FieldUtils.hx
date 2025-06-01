package fu.macros;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;

class FieldUtils {
    public static function hasField(name) {
        var fields = Context.getBuildFields();
        for (f in fields)
            if (f.name == name)
                return true;
        var lc = Context.getLocalClass().get();
        return hasFieldInClassType(lc, name);
    }

    public static function hasFieldInClassType(ct:ClassType, name) {
        for (f in ct.fields.get())
            if (f.name == name) {
                return true;
            }
        if (ct.superClass != null) {
            var r = hasFieldInClassType(ct.superClass.t.get(), name);
            return r;
        }
        return false;
    }

    public static function addField(fields:Array<Field>, name, type, ?e) {
        if (!hasField(name))
            fields.push({
                pos: Context.currentPos(),
                name: name,
                kind: FieldType.FVar(type, e),
            });
    }

    public static function addMethod(fields:Array<Field>, name, exprs:Array<Expr>, args:Array<FunctionArg> = null) {
        var access = null;
        if (args == null)
            args = [];
        if (hasFieldInClassType(Context.getLocalClass().get(), name)) {
            access = [AOverride];
            exprs.unshift(macro $p{["super", name]}($a{args.map(ar -> macro $i{ar.name})}));
        }
        fields.push({
            pos: Context.currentPos(),
            name: name,
            access: access,
            kind: FieldType.FFun({args: args, expr: {expr: EBlock(exprs), pos: Context.currentPos()}}),
        });
    }
}
