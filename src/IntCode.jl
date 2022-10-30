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

function add(p, x, y)
    a = p[x]
    b = p[y]
    p[a] + p[b]
end

function mul(p, x, y)
    a = p[x]
    b = p[y]
    p[a] * p[b]
end

function exec(p)
    pc = 0
    opcode = p[pc]
    while opcode != 99
        x = pc + 1
        y = pc + 2
        z = pc + 3
        a = p[z]
        if opcode == 1
            p[a] = add(p, x, y)
        elseif opcode == 2
            p[a] = mul(p, x, y)
        end
        pc = pc + 4
        opcode = p[pc]
    end
    p[0]
end


end # module IntCode
