module IntCode

greet() = println("Hello World!!")

function load(name)
    p = Dict()
    open(name, "r") do f
        s = read(f, String)
        for (i, x) in enumerate(eachsplit(s, ","))
            p[i-1] = parse(Int64, x)
        end
    end
    p
end

function add(p, x, y, px, py)
    a = px ? p[p[x]] : p[x]
    b = py ? p[p[y]] : p[y]
    a + b
end

function mul(p, x, y, px, py)
    a = px ? p[p[x]] : p[x]
    b = py ? p[p[y]] : p[y]
    a * b
end

function less(p, x, y, px, py)
    a = px ? p[p[x]] : p[x]
    b = py ? p[p[y]] : p[y]
    a < b ? 1 : 0
end

function eql(p, x, y, px, py)
    a = px ? p[p[x]] : p[x]
    b = py ? p[p[y]] : p[y]
    a == b ? 1 : 0
end

function jnz(pc, p, x, y, px, py)
    a = px ? p[p[x]] : p[x]
    b = py ? p[p[y]] : p[y]
    a > 0 ? b : pc + 3
end

function jz(pc, p, x, y, px, py)
    a = px ? p[p[x]] : p[x]
    b = py ? p[p[y]] : p[y]
    a == 0 ? b : pc + 3
end

function output(p, x, px)
    a = px ? p[p[x]] : p[x]
    println(a)
end

function exec(p)
    pc = 0
    opcode = p[pc]
    while opcode != 99
        args = [pc + 1, pc + 2, pc + 3]
        pc = op(pc, p, args, opcode)
        opcode = p[pc]
    end
    p[0]
end
n = 1
set_input(x) = global n = x
get_input() = n

function get_modes(opcode::Int64)
    s = "$opcode"
    s = lpad(s, 5, "0")
    #println(s)
    (s[3] == '0', s[2] == '0', s[3] == '0')
end

function op(pc, p, arg, opcode::Int64)
    (x, y, z) = get_modes(opcode)
    opcode = opcode % 100
    if opcode == 1
        a = p[arg[3]]
        p[a] = add(p, arg[1], arg[2], x, y)
        return pc + 4
    elseif opcode == 2
        a = p[arg[3]]
        p[a] = mul(p, arg[1], arg[2], x, y)
        return pc + 4
    elseif opcode == 3
        a = p[arg[1]]
        p[a] = get_input()
        return pc + 2
    elseif opcode == 4
        output(p, arg[1], x)
        return pc + 2
    elseif opcode == 5 # jump-if-true
        pc = jnz(pc, p, arg[1], arg[2], x, y)
        return pc
    elseif opcode == 6 # jump-if-false
        pc = jz(pc, p, arg[1], arg[2], x, y)
        return pc
    elseif opcode == 7
        a = p[arg[3]]
        p[a] = less(p, arg[1], arg[2], x, y)
        return pc + 4
    elseif opcode == 8
        a = p[arg[3]]
        p[a] = eql(p, arg[1], arg[2], x, y)
        return pc + 4
    else
        println("panic: unknown opcode $opcode")
        exit()
    end
end


end # module IntCode
