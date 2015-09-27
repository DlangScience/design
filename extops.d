import std.meta : Filter;
import std.traits : isBuiltinType, isInstanceOf;

struct ExtOp(alias F, string name_ = __traits(identifier, F))
{
    alias func = F;
    enum name = name_;
}

private enum isExtOp(T ...) = isInstanceOf!(ExtOp, T[0]);

private mixin template OverloadContainer(alias op)
{
    mixin(`alias ` ~ op.name ~ ` = op.func;`);
    mixin(`alias ` ~ op.name ~ ` = ` ~ op.name ~ `;`);
}

mixin template Overloads(T)
{
    static if(!isBuiltinType!T)
    {
        alias _Ops_ = Filter!(isExtOp, __traits(getAttributes, T));
        mixin({ import std.conv; string r;
            foreach(i, op; _Ops_)
            {
                r ~= `mixin OverloadContainer!(_Ops_[` ~ i.to!string ~ `]) `
                       ~ `_OverloadContainer_` ~ op.name ~ `;`;
                r ~= `alias ` ~ op.name ~ ` = _OverloadContainer_` ~ op.name
                       ~ `.` ~ op.name ~ `;`;
            }
            return r;
        }());
    }
}
