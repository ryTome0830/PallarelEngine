--- 型チェック関数
--- @param value any
--- @param kclass table|type
--- @return boolean
function TypeOf(value, kclass)
    if type(kclass) == "string" then
        return type(value) == kclass
    end

    if type(value) ~= "table" then
        return false
    end

    local mt = getmetatable(value)
    if mt and mt.__name == kclass.__name then
        return true
    end

    return false
end

--- tableの要素をすべて展開する
--- @param tbl table
--- @param indent? integer (default: 1)
--- @return string
function ExpandTable(tbl, indent)
    indent = indent or 1
    local result = "{\n"
    local indentStr = string.rep("  ", indent)

    for key, value in pairs(tbl) do
        result = result .. indentStr .. "  [" .. tostring(key) .. "] = "

        if type(value) == "table" and value ~= tbl then
            result = result .. ExpandTable(value, indent+1)
        else
            result = result .. tostring(value) .. ",\n"
        end
    end
    result = result .. indentStr .. "}"
    return result
end

--- tableから条件にあるオブジェクトを探す
--- @generic T
--- @param tbl T[]
--- @param predicate fun(item: T): boolean
--- @return number|nil, T|nil
function FindInTable(tbl, predicate)
    for i, element in ipairs(tbl) do
        if predicate(element) then
            return i, element
        end
    end
    return nil, nil
end

--- tableの要素を文字列に変換する
--- @param t table
--- @param indentLevel? number (default=0)
--- @return string
function ToStringTable(t, indentLevel)
    indentLevel = indentLevel or 0
    local indent = string.rep("    ", indentLevel)
    local nextIndent = string.rep("    ", indentLevel + 1)
    local parts = {}
    local isArray = true

    -- キーが1から始まる整数かチェック
    for k, _ in pairs(t) do
        if type(k) ~= "number" or k ~= math.floor(k) or k < 1 then
            isArray = false
            break
        end
    end

    for k, v in (isArray and ipairs or pairs)(t) do
        local keyStr
        if not isArray then
            keyStr = type(k) == "string" and k or tostring(k)
        else
            keyStr = nil -- 配列形式ではキーは省略
        end

        local valStr
        if type(v) == "table" then
            valStr = ToStringTable(v, indentLevel + 1)
        elseif type(v) == "string" then
            valStr = '"' .. v .. '"'
        else
            valStr = tostring(v)
        end

        local line = nextIndent
        if keyStr then
            line = line .. keyStr .. " = " .. valStr
        else
            line = line .. valStr
        end
        table.insert(parts, line)
    end

    return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
end

--- ファイルの存在をチェックし、存在しない場合は新規作成する
--- @param dir string
--- @param fileName string
--- @return file*|nil
function CheckExistanceFile(dir, fileName)
    local attempts = 0
    local basePath = dir .. "/" .. fileName 
    local filePath = basePath .. ".lua"

    while attempts < 3 do
        local f = io.open(filePath, "r")
        if not f then
            return io.open(filePath, "w")
        else
            f:close()
            attempts = attempts + 1
            -- string.formatにベースパス全体を渡す
            filePath = string.format("%s_%d.lua", basePath, attempts)
        end
    end
    return nil
end