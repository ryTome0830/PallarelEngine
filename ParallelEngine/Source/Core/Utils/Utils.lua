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
    local indent_str = string.rep("  ", indent)

    for key, value in pairs(tbl) do
        result = result .. indent_str .. "  [" .. tostring(key) .. "] = "

        if type(value) == "table" and value ~= tbl then
            result = result .. ExpandTable(value, indent+1)
        else
            result = result .. tostring(value) .. ",\n"
        end
    end
    result = result .. indent_str .. "}"
    return result
end