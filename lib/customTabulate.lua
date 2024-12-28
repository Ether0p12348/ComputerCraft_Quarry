local customTabulate = {}

function customTabulate.tabulate(colWidths, rows)
    for _, row in ipairs(rows) do
        local line = ""
        for colIndex, cell in ipairs(row) do
            local width = colWidths[colIndex] or 10
            local text = tostring(cell or "")

            if #text > width then
                text = text:sub(1, width - 1) .. "…"
            end

            local spacing = width - #text
            line = line .. text .. string.rep(" ", spacing)
        end
        print(line)
    end
end

function customTabulate.pagedTabulate(colWidths, rows, opts)
    opts = opts or {}
    local w, h = term.getSize()
    local pageSize = opts.pageSize or (h - 1)
    local doTruncate = (opts.truncate ~= false)

    local lineCount = 0
    for _, row in ipairs(rows) do
        local line = ""
        for colIndex, cell in ipairs(row) do
            local width = colWidths[colIndex] or 10
            local text = tostring(cell or "")

            if doTruncate and #text > width then
                text = text:sub(1, width - 1) .. "…"
            end

            local spacing = width - #text
            if spacing < 0 then
                spacing = 0
            end

            line = line .. text .. string.rep(" ", spacing)
        end

        print(line)
        lineCount = lineCount + 1

        if lineCount >= pageSize then
            write("Press <Enter> to continue, or type 'q' to quit...")
            local input = read(nil, nil, nil, "")
            if input:lower() == "q" then
                return
            end
            lineCount = 0
        end
    end

end

return customTabulate
