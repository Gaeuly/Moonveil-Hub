-- // ui/home/execute.lua
-- // Menyiapkan Wadah Halaman untuk Tab Execute

return function(Moonveil)
    local ExecuteTab = Moonveil.CreatedTabs.Execute
    if not ExecuteTab then return end

    -- Kita simpan referensi Page ini ke dalam Moonveil supaya bisa diakses file lain
    Moonveil.ExecutePage = ExecuteTab:CreatePage("Scripts")
end