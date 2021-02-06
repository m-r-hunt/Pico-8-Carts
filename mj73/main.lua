termina = require "termina.termina"

f = io.open("mj73.trm", "r")

code = f:read("*all")

compiled = termina.compile_for_pico8(code, "mj73.trm")

outf = io.open("mj73.lua", "w")
outf:write(compiled)
outf:close()
