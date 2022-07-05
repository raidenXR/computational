const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

const h = 0.00001;      // precision
const err = 0.001;      // error


fn simpleFunction(x: f64) f64
{
    // 4x + 3;
    // 4
    return 2.0*x*x + 3.0*x - 6.0;
}

pub fn forward(f: fn(f64) f64, x: f64) f64
{
    return (f(x + h) - f(x)) / h;
}

test "forward"
{
    const diff = forward(simpleFunction, 6.0);      // 27.0
    const _d = diff - 27.0;
    const abs = if(_d > 0) _d else -_d;

    print("diff: {d}\n", .{diff});
    
    try expect(abs < err);
}

pub fn central(f: fn(f64) f64, x: f64) f64
{
    return (f(x + h/2.0) - f(x - h/2.0)) / h;
}

pub fn extrapolated(f: fn(f64) f64, x: f64) f64
{
    return (f(x + h/4.0) - f(x - h/4.0)) / (h/2.0);
}

pub fn derivative2nd(f: fn(f64) f64, x: f64) f64
{
    return (f(x+h) + f(x-h) - 2.0*f(x)) / (h*h);
}

test "Derivative2nd"
{
    const diff = derivative2nd(simpleFunction, 6.0);    // 4.0
    const _d = diff - 4.0;
    const abs = if(_d > 0) _d else -_d;  
    print("diff: {d}\n", .{diff});
    try expect(abs < err);
}
