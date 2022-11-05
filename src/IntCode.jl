module IntCode
using DataStructures

function load(name)
    p = DefaultDict(0)
    open(name, "r") do f
        s = read(f, String)
        for (i, x) in enumerate(eachsplit(s, ","))
            p[i-1] = parse(Int64, x)
        end
    end
    p
end

# need to use thunks when using modes, as may be invalid references

function add(p, rb, x, y, px, py)
    a = Dict([('0', () -> p[p[x]]), ('1', () -> p[x]), ('2', () -> p[p[x]+rb])])
    b = Dict([('0', () -> p[p[y]]), ('1', () -> p[y]), ('2', () -> p[p[y]+rb])])
    a[px]() + b[py]()
end

function mul(p, rb, x, y, px, py)
    a = Dict([('0', () -> p[p[x]]), ('1', () -> p[x]), ('2', () -> p[p[x]+rb])])
    b = Dict([('0', () -> p[p[y]]), ('1', () -> p[y]), ('2', () -> p[p[y]+rb])])
    a[px]() * b[py]()
end

function less(p, rb, x, y, px, py)
    a = Dict([('0', () -> p[p[x]]), ('1', () -> p[x]), ('2', () -> p[p[x]+rb])])
    b = Dict([('0', () -> p[p[y]]), ('1', () -> p[y]), ('2', () -> p[p[y]+rb])])
    a[px]() < b[py]() ? 1 : 0
end

function eql(p, rb, x, y, px, py)
    a = Dict([('0', () -> p[p[x]]), ('1', () -> p[x]), ('2', () -> p[p[x]+rb])])
    b = Dict([('0', () -> p[p[y]]), ('1', () -> p[y]), ('2', () -> p[p[y]+rb])])
    a[px]() == b[py]() ? 1 : 0
end

function jnz(pc, rb, p, x, y, px, py)
    a = Dict([('0', () -> p[p[x]]), ('1', () -> p[x]), ('2', () -> p[p[x]+rb])])
    b = Dict([('0', () -> p[p[y]]), ('1', () -> p[y]), ('2', () -> p[p[y]+rb])])
    a[px]() > 0 ? b[py]() : pc + 3
end

function jz(pc, rb, p, x, y, px, py)
    a = Dict([('0', () -> p[p[x]]), ('1', () -> p[x]), ('2', () -> p[p[x]+rb])])
    b = Dict([('0', () -> p[p[y]]), ('1', () -> p[y]), ('2', () -> p[p[y]+rb])])
    a[px]() == 0 ? b[py]() : pc + 3
end

function output(p, rb, x, px, out::Channel)
    a = Dict([('0', () -> p[p[x]]), ('1', () -> p[x]), ('2', () -> p[p[x]+rb])])
    put!(out, a[px]())
end

function offset(p, rb, x, px)
    a = Dict([('0', () -> p[p[x]]), ('1', () -> p[x]), ('2', () -> p[p[x]+rb])])
    return rb + a[px]()
end

exec(p) = exec(p, Channel(Inf), Channel(1), Channel(1))
exec(p, in::Channel) = exec(p, Channel(Inf), in, Channel(1))
exec(p, out::Channel, in::Channel) = exec(p, out, in, Channel(1))

function exec(p, out::Channel, in::Channel, quit::Channel)
    pc = 0
    rb = 0
    opcode = p[pc]
    while opcode != 99
        args = [pc + 1, pc + 2, pc + 3]
        pc, rb = op(pc, rb, p, args, opcode, out, in, quit)
        opcode = p[pc]
    end
    close(in)
    close(out)
    close(quit)
end

function get_modes(opcode::Int64)
    s = "$opcode"
    s = lpad(s, 5, "0")
    (s[3], s[2], s[1])
end

function writeto(rb, arg, p, mode)
    a = Dict([('0', () -> p[arg]), ('1', () -> arg), ('2', () -> p[arg] + rb)])
    a[mode]()
end

function pretty_print(p, delim)
    xs = sort!(collect(keys(p)))
    println(typeof(xs))
    println(xs)
    for x in xs
        print(p[x], delim)
    end
    println()
end

function op(pc, rb, p, arg, opcode::Int64, out::Channel, in::Channel, quit::Channel)
    (x, y, z) = get_modes(opcode)

    opcode = opcode % 100
    if opcode == 1
        a = writeto(rb, arg[3], p, z)
        p[a] = add(p, rb, arg[1], arg[2], x, y)
        return pc + 4, rb
    elseif opcode == 2
        a = writeto(rb, arg[3], p, z)
        p[a] = mul(p, rb, arg[1], arg[2], x, y)
        return pc + 4, rb
    elseif opcode == 3
        a = writeto(rb, arg[1], p, x)
        p[a] = take!(in)
        return pc + 2, rb
    elseif opcode == 4
        output(p, rb, arg[1], x, out)
        return pc + 2, rb
    elseif opcode == 5 # jump-if-true
        pc = jnz(pc, rb, p, arg[1], arg[2], x, y)
        return pc, rb
    elseif opcode == 6 # jump-if-false
        pc = jz(pc, rb, p, arg[1], arg[2], x, y)
        return pc, rb
    elseif opcode == 7
        a = writeto(rb, arg[3], p, z)
        p[a] = less(p, rb, arg[1], arg[2], x, y)
        return pc + 4, rb
    elseif opcode == 8
        a = writeto(rb, arg[3], p, z)
        p[a] = eql(p, rb, arg[1], arg[2], x, y)
        return pc + 4, rb
    elseif opcode == 9
        rb = offset(p, rb, arg[1], x)
        return pc + 2, rb
    else
        println("panic: unknown opcode $opcode")
        close(in)
        close(out)
        close(quit)
        exit()
    end
end


end # module IntCode
