-- working lua base64 codec (c) 2006-2008 by Alex Kloss
-- compatible with lua 5.0
-- http://www.it-rfc.de
-- licensed under the terms of the LGPL2


base64 =  {}

-- bitshift functions (<<, >> equivalent)
function base64:lsh(value,shift)
    return math.mod((value*(2^shift)), 256)
end

-- shift right
function base64:rsh(value,shift)
    return math.mod(math.floor(value/2^shift), 256)
end

-- return single bit (for OR)
function base64:bit(x,b)
    return (math.mod(x, 2^b) - math.mod(x, 2^(b-1)) > 0)
end

-- logic OR for number values
function base64:lor(x,y)
    local result = 0
    for p=1,8 do result = result + (((self:bit(x,p) or self:bit(y,p)) == true) and 2^(p-1) or 0) end
    return result
end

-- decryption table
local base64bytes = {['A']=0,['B']=1,['C']=2,['D']=3,['E']=4,['F']=5,['G']=6,['H']=7,['I']=8,['J']=9,['K']=10,['L']=11,['M']=12,['N']=13,['O']=14,['P']=15,['Q']=16,['R']=17,['S']=18,['T']=19,['U']=20,['V']=21,['W']=22,['X']=23,['Y']=24,['Z']=25,['a']=26,['b']=27,['c']=28,['d']=29,['e']=30,['f']=31,['g']=32,['h']=33,['i']=34,['j']=35,['k']=36,['l']=37,['m']=38,['n']=39,['o']=40,['p']=41,['q']=42,['r']=43,['s']=44,['t']=45,['u']=46,['v']=47,['w']=48,['x']=49,['y']=50,['z']=51,['0']=52,['1']=53,['2']=54,['3']=55,['4']=56,['5']=57,['6']=58,['7']=59,['8']=60,['9']=61,['-']=62,['_']=63,['=']=nil}

-- function decode
-- decode base64 input to string
function base64:dec(data)
    local chars = {}
    local result=""
    for dpos=0,string.len(data)-1,4 do
        for char=1,4 do chars[char] = base64bytes[(string.sub(data,(dpos+char),(dpos+char)) or "=")] end
        result = string.format('%s%s%s%s',
                result,
                string.char(self:lor(self:lsh(chars[1],2), self:rsh(chars[2],4))),
                (chars[3] ~= nil) and string.char(self:lor(self:lsh(chars[2],4), self:rsh(chars[3],2))) or "",
                (chars[4] ~= nil) and string.char(self:lor(math.mod(self:lsh(chars[3],6), 192), (chars[4]))) or ""
        )
    end
    return result
end