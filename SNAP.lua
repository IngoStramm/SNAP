local ADDON_NAME = ...

local Snap = CreateFrame("Frame", "SNAPFrame")
local LOCALE = GetLocale and GetLocale() or "enUS"

local COLORS = {
    prefix = "|cff33ff99SNAP|r: ",
    green = "|cff66ff99",
    yellow = "|cffffd966",
    red = "|cffff6666",
    gray = "|cffbbbbbb",
    reset = "|r",
}

local L = {
    TITLE = "SNAP",
    LONG_TITLE = "SNAP - Swift NPC Auto Purchase",
    LOADED = "loaded. Use /snap config or /snap help.",
    OPTIONS = "Options",
    ENABLED = "Enabled",
    DISABLED = "Disabled",
    ENABLE_ADDON = "Enable auto buy",
    TEST_MODE = "Test mode (do not buy)",
    CHAT_MESSAGES = "Print chat messages",
    GLOBAL_LIMITS = "Global limits",
    MAX_SPEND = "Max gold per vendor visit",
    RESERVE_GOLD = "Gold to keep on character",
    ITEM_SETUP = "Add item",
    ITEM_ID = "Item ID or Shift-click item/link",
    MAX_PER_VISIT = "Max purchases per visit",
    MAX_PER_VISIT_SHORT = "Max buys",
    KEEP_QTY = "Buy until you have",
    KEEP_QTY_SHORT = "Keep qty",
    MAX_UNIT_PRICE = "Max unit price (gold)",
    MAX_UNIT_PRICE_SHORT = "Max unit g",
    ADD = "Add",
    CLEAR = "Clear",
    ITEMS = "Configured items",
    ITEM = "Item",
    ACTIVE = "On",
    REMOVE = "Remove",
    NO_ITEMS = "No configured items yet.",
    INVALID_ITEM = "Invalid item ID or item link.",
    ADDED = "Added item #%d.",
    DUPLICATE_ITEM = "Item #%d is already configured. Edit it in the configured items list.",
    REMOVED = "Removed item #%d.",
    BOUGHT = "Bought: %dx %s (%s).",
    WOULD_BUY = "Test: %dx %s (%s).",
    SKIP_PRICE = "Price too high: %s (%s > %s).",
    SKIP_BUDGET = "Gold limit reached.",
    HELP_HEADER = "SNAP commands:",
    HELP_CONFIG = "/snap config - open options",
    HELP_ON = "/snap on - enable auto buy",
    HELP_OFF = "/snap off - disable auto buy",
    HELP_TEST = "/snap test - toggle test mode",
    HELP_DEBUG = "/snap debug - toggle debug messages",
    HELP_SCAN = "/snap scan - scan the open vendor now",
    HELP_ADD = "/snap add <itemID|item link> [max per visit]",
    HELP_REMOVE = "/snap remove <itemID>",
    HELP_LIST = "/snap list - list configured items",
    HELP_STATUS = "/snap status - show current limits",
    STATUS = "Status",
    ON = "on",
    OFF = "off",
    GOLD = "g",
    SILVER = "s",
    COPPER = "c",
    DEBUG = "Debug",
    DEBUG_ON = "Debug enabled.",
    DEBUG_OFF = "Debug disabled.",
    DEBUG_SCAN = "Vendor has %d items.",
    DEBUG_DISABLED = "skip %s: item is disabled.",
    DEBUG_EXTENDED = "skip %s: item uses extended cost.",
    DEBUG_DESIRED = "%s: desired purchases=%d, unit qty=%d, price=%s, budget=%s.",
    DEBUG_BUY = "%s: buying %d purchase(s), %d unit(s), total %s.",
}

if LOCALE == "ptBR" then
    L = {
        TITLE = "SNAP",
        LONG_TITLE = "SNAP - Swift NPC Auto Purchase",
        LOADED = "carregado. Use /snap config ou /snap help.",
        OPTIONS = "Opcoes",
        ENABLED = "Ativado",
        DISABLED = "Desativado",
        ENABLE_ADDON = "Ativar compra automatica",
        TEST_MODE = "Modo teste (nao comprar)",
        CHAT_MESSAGES = "Mostrar mensagens no chat",
        GLOBAL_LIMITS = "Limites globais",
        MAX_SPEND = "Maximo de gold por visita ao vendedor",
        RESERVE_GOLD = "Gold para manter no personagem",
        ITEM_SETUP = "Adicionar item",
        ITEM_ID = "Item ID ou Shift+click no item/link",
        MAX_PER_VISIT = "Max compras por visita",
        MAX_PER_VISIT_SHORT = "Max compras",
        KEEP_QTY = "Comprar ate ter",
        KEEP_QTY_SHORT = "Manter qtd",
        MAX_UNIT_PRICE = "Preco max por unidade (gold)",
        MAX_UNIT_PRICE_SHORT = "Max un. g",
        ADD = "Adicionar",
        CLEAR = "Limpar",
        ITEMS = "Itens configurados",
        ITEM = "Item",
        ACTIVE = "Ativo",
        REMOVE = "Remover",
        NO_ITEMS = "Nenhum item configurado ainda.",
        INVALID_ITEM = "Item ID ou link de item invalido.",
        ADDED = "Item #%d adicionado.",
        DUPLICATE_ITEM = "Item #%d ja esta configurado. Edite o item na lista de itens cadastrados.",
        REMOVED = "Item #%d removido.",
        BOUGHT = "Comprou: %dx %s (%s).",
        WOULD_BUY = "Teste: %dx %s (%s).",
        SKIP_PRICE = "Preco alto: %s (%s > %s).",
        SKIP_BUDGET = "Limite de gold atingido.",
        HELP_HEADER = "Comandos do SNAP:",
        HELP_CONFIG = "/snap config - abrir opcoes",
        HELP_ON = "/snap on - ativar compra automatica",
        HELP_OFF = "/snap off - desativar compra automatica",
        HELP_TEST = "/snap test - alternar modo teste",
        HELP_DEBUG = "/snap debug - alternar mensagens de debug",
        HELP_SCAN = "/snap scan - escanear o vendedor aberto agora",
        HELP_ADD = "/snap add <itemID|link do item> [max por visita]",
        HELP_REMOVE = "/snap remove <itemID>",
        HELP_LIST = "/snap list - listar itens configurados",
        HELP_STATUS = "/snap status - mostrar limites atuais",
        STATUS = "Status",
        ON = "on",
        OFF = "off",
        GOLD = "g",
        SILVER = "s",
        COPPER = "c",
        DEBUG = "Debug",
        DEBUG_ON = "Debug ativado.",
        DEBUG_OFF = "Debug desativado.",
        DEBUG_SCAN = "Vendedor tem %d itens.",
        DEBUG_DISABLED = "ignorou %s: item desativado.",
        DEBUG_EXTENDED = "ignorou %s: item usa custo especial.",
        DEBUG_DESIRED = "%s: compras desejadas=%d, qtd por compra=%d, preco=%s, orcamento=%s.",
        DEBUG_BUY = "%s: comprando %d compra(s), %d unidade(s), total %s.",
    }
end

local DEFAULT_DB = {
    version = 1,
    enabled = true,
    testMode = true,
    chat = true,
    debug = false,
    maxSpend = 10000,
    reserveGold = 0,
    items = {},
}

local db
local optionsPanel
local settingsCategory
local standaloneWindow
local scanQueued = false
local currentVisit = 0
local spentThisVisit = 0
local boughtThisVisit = {}
local purchasesThisVisit = {}
local matchedThisVisit = false
local lastSkipBudgetMessage = 0
local optionRows = {}
local itemIdEdit
local itemIdCaptureArmed = false
local maxPerVisitEdit
local keepQtyEdit
local maxUnitPriceEdit
local originalChatEditInsertLink
local originalHandleModifiedItemClick
local originalContainerFrameItemButtonOnModifiedClick

local function CopyDefaults(source)
    local copy = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            copy[key] = CopyDefaults(value)
        else
            copy[key] = value
        end
    end
    return copy
end

local function MergeDefaults(target, defaults)
    if type(target) ~= "table" then
        target = {}
    end

    for key, value in pairs(defaults) do
        if type(value) == "table" then
            target[key] = MergeDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end

    return target
end

local function EnsureDb()
    if type(SNAPDB) ~= "table" then
        SNAPDB = CopyDefaults(DEFAULT_DB)
    else
        SNAPDB = MergeDefaults(SNAPDB, DEFAULT_DB)
    end

    db = SNAPDB
    if type(db.items) ~= "table" then
        db.items = {}
    end
    db.maxSpend = tonumber(db.maxSpend) or 0
    db.reserveGold = tonumber(db.reserveGold) or 0
    db.enabled = db.enabled and true or false
    db.testMode = db.testMode and true or false
    db.chat = db.chat and true or false
    db.debug = db.chat and db.debug and true or false

    return db
end

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage(COLORS.prefix .. tostring(message))
end

local function Debug(message)
    if db and db.chat and db.debug then
        Print(L.DEBUG .. ": " .. tostring(message))
    end
end

local function Trim(text)
    text = tostring(text or "")
    return text:match("^%s*(.-)%s*$") or ""
end

local function ExtractItemID(value)
    value = Trim(value)
    if value == "" then
        return nil
    end

    local id = value:match("item:(%d+)")
    if id then
        return tonumber(id)
    end

    id = value:match("Hitem:(%d+)")
    if id then
        return tonumber(id)
    end

    id = value:match("^(%d+)$")
    if id then
        return tonumber(id)
    end

    return nil
end

local function GetItemLinkFromID(itemID)
    if GetItemInfo then
        local name, link = GetItemInfo(itemID)
        return link, name
    end
    return nil, nil
end

local function GetItemName(itemID)
    local link, name = GetItemLinkFromID(itemID)
    return link or name or ("Item #" .. tostring(itemID))
end

local function FormatMoney(copper)
    copper = math.max(0, math.floor(tonumber(copper) or 0))
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local bronze = copper % 100

    if gold > 0 then
        return string.format("%d%s %02d%s %02d%s", gold, L.GOLD, silver, L.SILVER, bronze, L.COPPER)
    elseif silver > 0 then
        return string.format("%d%s %02d%s", silver, L.SILVER, bronze, L.COPPER)
    end
    return string.format("%d%s", bronze, L.COPPER)
end

local function ParseGoldToCopper(value)
    value = Trim(value):gsub(",", ".")
    if value == "" then
        return 0
    end

    local number = tonumber(value)
    if not number then
        return 0
    end

    return math.max(0, math.floor((number * 10000) + 0.5))
end

local function CopperToGoldText(copper)
    copper = tonumber(copper) or 0
    if copper <= 0 then
        return ""
    end

    local gold = copper / 10000
    if gold == math.floor(gold) then
        return tostring(math.floor(gold))
    end
    return string.format("%.2f", gold)
end

local function NormalizeItem(itemID)
    local key = tostring(itemID)
    local item = db.items[key]
    if type(item) ~= "table" then
        item = {}
        db.items[key] = item
    end

    item.itemID = itemID
    if item.enabled == nil then
        item.enabled = true
    end
    item.maxPerVisit = math.max(0, math.floor(tonumber(item.maxPerVisit) or 1))
    item.keepQty = math.max(0, math.floor(tonumber(item.keepQty) or 0))
    item.maxUnitPrice = math.max(0, math.floor(tonumber(item.maxUnitPrice) or 0))
    return item
end

local function AddItem(itemID, maxPerVisit, keepQty, maxUnitPrice)
    EnsureDb()
    if not itemID or itemID <= 0 then
        Print(L.INVALID_ITEM)
        return false
    end

    if db.items[tostring(itemID)] ~= nil then
        Print(L.DUPLICATE_ITEM:format(itemID))
        if Snap.RefreshOptions then
            Snap:RefreshOptions(true)
        end
        return false
    end

    local item = NormalizeItem(itemID)
    item.enabled = true
    item.maxPerVisit = math.max(0, math.floor(tonumber(maxPerVisit) or item.maxPerVisit or 1))
    item.keepQty = math.max(0, math.floor(tonumber(keepQty) or item.keepQty or 0))
    item.maxUnitPrice = math.max(0, math.floor(tonumber(maxUnitPrice) or item.maxUnitPrice or 0))

    if db.chat then
        Print(L.ADDED:format(itemID))
    end

    if Snap.RefreshOptions then
        Snap:RefreshOptions()
    end
    return true
end

local function RemoveItem(itemID)
    EnsureDb()
    if itemID and db.items[tostring(itemID)] then
        db.items[tostring(itemID)] = nil
        Print(L.REMOVED:format(itemID))
        if Snap.RefreshOptions then
            Snap:RefreshOptions()
        end
        return true
    end
    Print(L.INVALID_ITEM)
    return false
end

local function GetSortedItems()
    EnsureDb()
    local list = {}
    for key, item in pairs(db.items) do
        local itemID = tonumber(key) or tonumber(item.itemID)
        if itemID then
            NormalizeItem(itemID)
            list[#list + 1] = db.items[tostring(itemID)]
        end
    end

    table.sort(list, function(a, b)
        return (a.itemID or 0) < (b.itemID or 0)
    end)

    return list
end

local function GetMerchantItemID(index)
    if GetMerchantItemLink then
        local link = GetMerchantItemLink(index)
        return ExtractItemID(link), link
    end
    return nil, nil
end

local function GetAvailableBudget()
    local money = GetMoney and GetMoney() or 0
    local globalRemaining = math.max(0, (db.maxSpend or 0) - spentThisVisit)
    local reserveRemaining = math.max(0, money - (db.reserveGold or 0))

    if db.maxSpend and db.maxSpend > 0 then
        return math.min(globalRemaining, reserveRemaining)
    end
    return reserveRemaining
end

local function GetOwnedCount(itemID)
    if GetItemCount then
        local ok, count = pcall(GetItemCount, itemID, false, true)
        if ok and count then
            return count
        end
        ok, count = pcall(GetItemCount, itemID)
        if ok and count then
            return count
        end
    end
    return 0
end

local function GetDesiredQuantity(item, available)
    local desiredPurchases
    local boughtUnits = boughtThisVisit[item.itemID] or 0
    local purchases = purchasesThisVisit[item.itemID] or 0

    if item.maxPerVisit and item.maxPerVisit > 0 then
        desiredPurchases = math.max(0, item.maxPerVisit - purchases)
    end

    if item.keepQty and item.keepQty > 0 then
        local stackSize = math.max(1, tonumber(item.stackSize) or 1)
        local missing = math.max(0, item.keepQty - GetOwnedCount(item.itemID) - boughtUnits)
        local purchasesNeeded = math.ceil(missing / stackSize)
        if desiredPurchases then
            desiredPurchases = math.min(desiredPurchases, purchasesNeeded)
        else
            desiredPurchases = purchasesNeeded
        end
    end

    desiredPurchases = desiredPurchases or 1

    if available and available > 0 then
        desiredPurchases = math.min(desiredPurchases, available)
    end

    return math.max(0, math.floor(desiredPurchases))
end

local function BuyVendorItem(index, itemID, item, name, price, stackSize, available)
    if not item.enabled then
        Debug(L.DEBUG_DISABLED:format(name or GetItemName(itemID)))
        return
    end

    price = tonumber(price) or 0
    stackSize = tonumber(stackSize) or 1
    if stackSize < 1 then
        stackSize = 1
    end

    local unitPrice = price / stackSize
    if item.maxUnitPrice and item.maxUnitPrice > 0 and unitPrice > item.maxUnitPrice then
        if db.chat then
            Print(L.SKIP_PRICE:format(name or GetItemName(itemID), FormatMoney(unitPrice), FormatMoney(item.maxUnitPrice)))
        end
        return
    end

    item.stackSize = stackSize
    local desiredPurchases = GetDesiredQuantity(item, available)
    Debug(L.DEBUG_DESIRED:format(name or GetItemName(itemID), desiredPurchases, stackSize, FormatMoney(price), FormatMoney(GetAvailableBudget())))
    if desiredPurchases <= 0 then
        return
    end

    local budget = GetAvailableBudget()
    if price > 0 then
        desiredPurchases = math.min(desiredPurchases, math.floor(budget / price))
    end

    if desiredPurchases <= 0 then
        local now = GetTime and GetTime() or 0
        if db.chat and now - lastSkipBudgetMessage > 1 then
            lastSkipBudgetMessage = now
            Print(L.SKIP_BUDGET)
        end
        return
    end

    local unitsToBuy = desiredPurchases * stackSize
    local totalCost = desiredPurchases * price
    if totalCost <= 0 then
        totalCost = math.ceil(unitsToBuy * unitPrice)
    end

    if db.testMode then
        if db.chat then
            Print(L.WOULD_BUY:format(unitsToBuy, name or GetItemName(itemID), FormatMoney(totalCost)))
        end
        spentThisVisit = spentThisVisit + totalCost
        boughtThisVisit[itemID] = (boughtThisVisit[itemID] or 0) + unitsToBuy
        purchasesThisVisit[itemID] = (purchasesThisVisit[itemID] or 0) + desiredPurchases
        return
    end

    if BuyMerchantItem then
        Debug(L.DEBUG_BUY:format(name or GetItemName(itemID), desiredPurchases, unitsToBuy, FormatMoney(totalCost)))
        for _ = 1, desiredPurchases do
            BuyMerchantItem(index)
        end
        spentThisVisit = spentThisVisit + totalCost
        boughtThisVisit[itemID] = (boughtThisVisit[itemID] or 0) + unitsToBuy
        purchasesThisVisit[itemID] = (purchasesThisVisit[itemID] or 0) + desiredPurchases

        if db.chat then
            Print(L.BOUGHT:format(unitsToBuy, name or GetItemName(itemID), FormatMoney(totalCost)))
        end
    end
end

function Snap:ScanMerchant()
    EnsureDb()
    if not db.enabled or not GetMerchantNumItems then
        return
    end

    local count = GetMerchantNumItems() or 0
    Debug(L.DEBUG_SCAN:format(count))
    for index = 1, count do
        local name, _, price, stackSize, available, _, extendedCost = GetMerchantItemInfo(index)
        local itemID = GetMerchantItemID(index)
        local item = itemID and db.items[tostring(itemID)]
        if item and extendedCost and (not price or price <= 0) then
            Debug(L.DEBUG_EXTENDED:format(name or GetItemName(itemID)))
        elseif item then
            matchedThisVisit = true
            item = NormalizeItem(itemID)
            BuyVendorItem(index, itemID, item, name, price, stackSize, available)
        end
    end
end

function Snap:QueueScan(delay)
    if scanQueued then
        return
    end

    scanQueued = true
    if C_Timer and C_Timer.After then
        C_Timer.After(delay or 0.05, function()
            scanQueued = false
            Snap:ScanMerchant()
        end)
    else
        scanQueued = false
        Snap:ScanMerchant()
    end
end

function Snap:StartVisit()
    currentVisit = currentVisit + 1
    spentThisVisit = 0
    boughtThisVisit = {}
    purchasesThisVisit = {}
    matchedThisVisit = false
    self:QueueScan(0.05)
    if C_Timer and C_Timer.After then
        local visit = currentVisit
        C_Timer.After(0.25, function()
            if visit == currentVisit and not matchedThisVisit then
                Snap:ScanMerchant()
            end
        end)
    end
end

local function CreateText(parent, text, template)
    local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
    fs:SetText(text)
    fs:SetJustifyH("LEFT")
    return fs
end

local function CreateButton(parent, text, width)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 100, 24)
    button:SetText(text)
    return button
end

local function SetCheckboxLabel(check, text)
    if check.Text then
        check.Text:SetText(text)
    elseif check.text then
        check.text:SetText(text)
    else
        local label = check:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", check, "RIGHT", 2, 0)
        label:SetText(text)
        check.Text = label
    end
end

local function CreateCheckbox(parent, text, getter, setter)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetSize(24, 24)
    SetCheckboxLabel(check, text)
    check:SetScript("OnShow", function(self)
        self:SetChecked(getter() and true or false)
    end)
    check:SetScript("OnClick", function(self)
        setter(self:GetChecked() and true or false)
        Snap:RefreshOptions()
    end)
    return check
end

local function CreateEditBox(parent, width, numeric)
    local edit = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    edit:SetSize(width or 80, 22)
    edit:SetAutoFocus(false)
    edit:SetJustifyH("LEFT")
    edit:SetTextColor(1, 1, 1, 1)
    if edit.SetFontObject then
        edit:SetFontObject(GameFontHighlightSmall)
    end
    if edit.SetTextInsets then
        edit:SetTextInsets(6, 4, 0, 0)
    end
    if numeric then
        edit:SetNumeric(true)
    end
    return edit
end

local function AddLabeledEdit(parent, label, x, y, width, numeric)
    local text = CreateText(parent, label, "GameFontNormalSmall")
    text:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    local edit = CreateEditBox(parent, width, numeric)
    edit:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y - 16)
    return edit, text
end

local function FocusedItemEdit()
    if itemIdEdit and itemIdEdit.HasFocus and itemIdEdit:HasFocus() then
        return true
    end
    return itemIdCaptureArmed and optionsPanel and optionsPanel:IsShown()
end

local function FillFocusedItemEdit(link)
    if not FocusedItemEdit() then
        return false
    end

    local itemID = ExtractItemID(link)
    if itemID then
        itemIdCaptureArmed = false
        itemIdEdit.savedText = tostring(itemID)
        itemIdEdit:SetFocus()
        if itemIdEdit.displayValue then
            itemIdEdit.displayValue:Hide()
        end
        itemIdEdit:SetText(tostring(itemID))
        itemIdEdit:HighlightText()
        return true
    end

    return false
end

local function HookItemLinkInsertion()
    if not originalChatEditInsertLink and type(ChatEdit_InsertLink) == "function" then
        originalChatEditInsertLink = ChatEdit_InsertLink
        ChatEdit_InsertLink = function(link, ...)
            if FillFocusedItemEdit(link) then
                return true
            end
            return originalChatEditInsertLink(link, ...)
        end
    end

    if not originalHandleModifiedItemClick and type(HandleModifiedItemClick) == "function" then
        originalHandleModifiedItemClick = HandleModifiedItemClick
        HandleModifiedItemClick = function(link, ...)
            if FillFocusedItemEdit(link) then
                if StackSplitFrame and StackSplitFrame.Hide then
                    StackSplitFrame:Hide()
                end
                return true
            end
            return originalHandleModifiedItemClick(link, ...)
        end
    end

    if not originalContainerFrameItemButtonOnModifiedClick and type(ContainerFrameItemButton_OnModifiedClick) == "function" then
        originalContainerFrameItemButtonOnModifiedClick = ContainerFrameItemButton_OnModifiedClick
        ContainerFrameItemButton_OnModifiedClick = function(self, button, ...)
            if FocusedItemEdit() and self then
                local link
                local bag = self:GetParent() and self:GetParent():GetID()
                local slot = self:GetID()

                if C_Container and C_Container.GetContainerItemLink then
                    link = C_Container.GetContainerItemLink(bag, slot)
                elseif GetContainerItemLink then
                    link = GetContainerItemLink(bag, slot)
                end

                if FillFocusedItemEdit(link) then
                    if StackSplitFrame and StackSplitFrame.Hide then
                        StackSplitFrame:Hide()
                    end
                    return true
                end
            end

            return originalContainerFrameItemButtonOnModifiedClick(self, button, ...)
        end
    end
end

local function GetEditValue(edit)
    local text = edit and Trim(edit:GetText()) or ""
    if text == "" and edit and edit.savedText then
        text = Trim(edit.savedText)
    end
    return text
end

local SetDisplayValue

local function UpdateGlobalEdit(edit, value, force)
    if edit and (force or not edit:HasFocus()) then
        SetDisplayValue(edit, CopperToGoldText(value))
    end
end

local function ResetAddItemInputs()
    if itemIdEdit then
        SetDisplayValue(itemIdEdit, "")
        itemIdEdit:ClearFocus()
    end
    if maxPerVisitEdit then
        SetDisplayValue(maxPerVisitEdit, "1")
        maxPerVisitEdit:ClearFocus()
    end
    if keepQtyEdit then
        SetDisplayValue(keepQtyEdit, "0")
        keepQtyEdit:ClearFocus()
    end
    if maxUnitPriceEdit then
        SetDisplayValue(maxUnitPriceEdit, "")
        maxUnitPriceEdit:ClearFocus()
    end
    itemIdCaptureArmed = false
end

local function SaveItemFromInputs()
    local itemID = ExtractItemID(GetEditValue(itemIdEdit))
    if not itemID then
        Print(L.INVALID_ITEM)
        return
    end

    local maxPerVisit = tonumber(GetEditValue(maxPerVisitEdit)) or 1
    local keepQty = tonumber(GetEditValue(keepQtyEdit)) or 0
    local maxUnitPrice = ParseGoldToCopper(GetEditValue(maxUnitPriceEdit))
    if AddItem(itemID, maxPerVisit, keepQty, maxUnitPrice) then
        ResetAddItemInputs()
    end
end

local function ReadPositiveInteger(text, fallback)
    text = Trim(text)
    if text == "" then
        return fallback
    end
    return math.max(0, math.floor(tonumber(text) or fallback or 0))
end

local function AttachDisplayValue(edit, width)
    local text = edit:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", edit, "LEFT", 7, 0)
    text:SetSize((width or 60) - 12, 18)
    text:SetJustifyH("LEFT")
    text:SetTextColor(1, 1, 1, 1)
    edit.displayValue = text
    edit.savedText = ""

    local function OnFocusGained(self)
        if self.displayValue then
            self.displayValue:Hide()
        end
        self:SetText(self.savedText or "")
        self:HighlightText()
    end

    if edit.HookScript then
        edit:HookScript("OnEditFocusGained", OnFocusGained)
    else
        edit:SetScript("OnEditFocusGained", OnFocusGained)
    end

    return text
end

SetDisplayValue = function(edit, value)
    local text = tostring(value or "")
    edit.savedText = text

    if edit:HasFocus() then
        edit:SetText(text)
        if edit.displayValue then
            edit.displayValue:Hide()
        end
    else
        edit:SetText("")
        if edit.displayValue then
            edit.displayValue:SetText(text)
            edit.displayValue:Show()
        end
    end
end

local function CreateItemRow(parent, index)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(620, 24)

    row.enabled = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    row.enabled:SetSize(22, 22)
    row.enabled:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.enabled:SetScript("OnClick", function(self)
        if row.itemID then
            local item = db.items[tostring(row.itemID)]
            if item then
                item.enabled = self:GetChecked() and true or false
            end
        end
    end)

    row.name = CreateText(row, "", "GameFontHighlightSmall")
    row.name:SetPoint("LEFT", row, "LEFT", 40, 0)
    row.name:SetSize(220, 18)
    row.name:SetJustifyH("LEFT")

    row.tooltipButton = CreateFrame("Button", nil, row)
    row.tooltipButton:SetPoint("LEFT", row, "LEFT", 40, 0)
    row.tooltipButton:SetSize(220, 20)
    row.tooltipButton:SetScript("OnEnter", function(self)
        if not row.itemID or not GameTooltip then
            return
        end

        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local link = select(2, GetItemInfo(row.itemID))
        if link and GameTooltip.SetHyperlink then
            GameTooltip:SetHyperlink(link)
        elseif GameTooltip.SetItemByID then
            GameTooltip:SetItemByID(row.itemID)
        else
            GameTooltip:SetText(GetItemName(row.itemID))
            GameTooltip:AddLine("Item ID: " .. tostring(row.itemID), 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    row.tooltipButton:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    row.maxEdit = CreateEditBox(row, 68, true)
    row.maxEdit:SetPoint("LEFT", row, "LEFT", 275, 0)
    AttachDisplayValue(row.maxEdit, 68)
    row.maxEdit:SetScript("OnEnterPressed", function(self)
        if row.itemID then
            local item = db.items[tostring(row.itemID)]
            if item then
                item.maxPerVisit = ReadPositiveInteger(self:GetText(), item.maxPerVisit or 1)
            end
        end
        self:ClearFocus()
    end)
    row.maxEdit:SetScript("OnEditFocusLost", function(self)
        if row.itemID then
            local item = db.items[tostring(row.itemID)]
            if item then
                item.maxPerVisit = ReadPositiveInteger(self:GetText(), item.maxPerVisit or 1)
                SetDisplayValue(self, item.maxPerVisit or 0)
            end
        end
    end)

    row.keepEdit = CreateEditBox(row, 68, true)
    row.keepEdit:SetPoint("LEFT", row, "LEFT", 365, 0)
    AttachDisplayValue(row.keepEdit, 68)
    row.keepEdit:SetScript("OnEnterPressed", function(self)
        if row.itemID then
            local item = db.items[tostring(row.itemID)]
            if item then
                item.keepQty = ReadPositiveInteger(self:GetText(), item.keepQty or 0)
            end
        end
        self:ClearFocus()
    end)
    row.keepEdit:SetScript("OnEditFocusLost", function(self)
        if row.itemID then
            local item = db.items[tostring(row.itemID)]
            if item then
                item.keepQty = ReadPositiveInteger(self:GetText(), item.keepQty or 0)
                SetDisplayValue(self, item.keepQty or 0)
            end
        end
    end)

    row.priceEdit = CreateEditBox(row, 82, false)
    row.priceEdit:SetPoint("LEFT", row, "LEFT", 455, 0)
    AttachDisplayValue(row.priceEdit, 82)
    row.priceEdit:SetScript("OnEnterPressed", function(self)
        if row.itemID then
            local item = db.items[tostring(row.itemID)]
            if item then
                item.maxUnitPrice = ParseGoldToCopper(self:GetText())
            end
        end
        self:ClearFocus()
    end)
    row.priceEdit:SetScript("OnEditFocusLost", function(self)
        if row.itemID then
            local item = db.items[tostring(row.itemID)]
            if item then
                item.maxUnitPrice = ParseGoldToCopper(self:GetText())
                SetDisplayValue(self, CopperToGoldText(item.maxUnitPrice))
            end
        end
    end)

    row.remove = CreateButton(row, L.REMOVE, 70)
    row.remove:SetPoint("LEFT", row, "LEFT", 550, 0)
    row.remove:SetScript("OnClick", function()
        if row.itemID then
            RemoveItem(row.itemID)
        end
    end)

    optionRows[index] = row
    return row
end

function Snap:RefreshOptions(force)
    EnsureDb()
    if not optionsPanel then
        return
    end

    if optionsPanel.enabledCheck then
        optionsPanel.enabledCheck:SetChecked(db.enabled)
    end
    if optionsPanel.testCheck then
        optionsPanel.testCheck:SetChecked(db.testMode)
    end
    if optionsPanel.chatCheck then
        optionsPanel.chatCheck:SetChecked(db.chat)
    end
    UpdateGlobalEdit(optionsPanel.maxSpendEdit, db.maxSpend, force)
    UpdateGlobalEdit(optionsPanel.reserveGoldEdit, db.reserveGold, force)

    local items = GetSortedItems()
    if optionsPanel.emptyText then
        if #items == 0 then
            optionsPanel.emptyText:Show()
        else
            optionsPanel.emptyText:Hide()
        end
    end

    for index = 1, #optionRows do
        local row = optionRows[index]
        local item = items[index]
        if item then
            row.itemID = item.itemID
            row.enabled:SetChecked(item.enabled)
            row.name:SetText(GetItemName(item.itemID))
            if force or not row.maxEdit:HasFocus() then
                SetDisplayValue(row.maxEdit, item.maxPerVisit or 0)
            end
            if force or not row.keepEdit:HasFocus() then
                SetDisplayValue(row.keepEdit, item.keepQty or 0)
            end
            if force or not row.priceEdit:HasFocus() then
                SetDisplayValue(row.priceEdit, CopperToGoldText(item.maxUnitPrice))
            end
            row:Show()
        else
            row.itemID = nil
            row:Hide()
        end
    end
end

function Snap:CreateOptionsPanel()
    if optionsPanel then
        return optionsPanel
    end

    EnsureDb()
    local panel = CreateFrame("Frame", "SNAPOptionsPanel")
    panel.name = L.TITLE

    local title = CreateText(panel, L.LONG_TITLE, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)

    panel.enabledCheck = CreateCheckbox(panel, L.ENABLE_ADDON, function() return db.enabled end, function(value) db.enabled = value end)
    panel.enabledCheck:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -48)

    panel.testCheck = CreateCheckbox(panel, L.TEST_MODE, function() return db.testMode end, function(value) db.testMode = value end)
    panel.testCheck:SetPoint("LEFT", panel.enabledCheck, "RIGHT", 190, 0)

    panel.chatCheck = CreateCheckbox(panel, L.CHAT_MESSAGES, function() return db.chat end, function(value) db.chat = value end)
    panel.chatCheck:SetPoint("LEFT", panel.testCheck, "RIGHT", 190, 0)

    local globalTitle = CreateText(panel, L.GLOBAL_LIMITS, "GameFontNormal")
    globalTitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -86)

    panel.maxSpendEdit = AddLabeledEdit(panel, L.MAX_SPEND, 16, -112, 110, false)
    panel.reserveGoldEdit = AddLabeledEdit(panel, L.RESERVE_GOLD, 170, -112, 110, false)
    AttachDisplayValue(panel.maxSpendEdit, 110)
    AttachDisplayValue(panel.reserveGoldEdit, 110)

    panel.maxSpendEdit:SetScript("OnEnterPressed", function(self)
        db.maxSpend = ParseGoldToCopper(self:GetText())
        self:ClearFocus()
    end)
    panel.maxSpendEdit:SetScript("OnEditFocusLost", function(self)
        db.maxSpend = ParseGoldToCopper(self:GetText())
        SetDisplayValue(self, CopperToGoldText(db.maxSpend))
    end)

    panel.reserveGoldEdit:SetScript("OnEnterPressed", function(self)
        db.reserveGold = ParseGoldToCopper(self:GetText())
        self:ClearFocus()
    end)
    panel.reserveGoldEdit:SetScript("OnEditFocusLost", function(self)
        db.reserveGold = ParseGoldToCopper(self:GetText())
        SetDisplayValue(self, CopperToGoldText(db.reserveGold))
    end)

    local addTitle = CreateText(panel, L.ITEM_SETUP, "GameFontNormal")
    addTitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -164)

    itemIdEdit = AddLabeledEdit(panel, L.ITEM_ID, 16, -190, 210, false)
    maxPerVisitEdit = AddLabeledEdit(panel, L.MAX_PER_VISIT_SHORT, 250, -190, 72, true)
    keepQtyEdit = AddLabeledEdit(panel, L.KEEP_QTY_SHORT, 345, -190, 72, true)
    maxUnitPriceEdit = AddLabeledEdit(panel, L.MAX_UNIT_PRICE_SHORT, 440, -190, 86, false)
    AttachDisplayValue(itemIdEdit, 210)
    AttachDisplayValue(maxPerVisitEdit, 72)
    AttachDisplayValue(keepQtyEdit, 72)
    AttachDisplayValue(maxUnitPriceEdit, 86)
    ResetAddItemInputs()
    maxPerVisitEdit:SetScript("OnEditFocusGained", function()
        itemIdCaptureArmed = false
    end)
    keepQtyEdit:SetScript("OnEditFocusGained", function()
        itemIdCaptureArmed = false
    end)
    maxUnitPriceEdit:SetScript("OnEditFocusGained", function()
        itemIdCaptureArmed = false
    end)

    itemIdEdit:SetScript("OnEnterPressed", function(self)
        SaveItemFromInputs()
        self:ClearFocus()
    end)
    itemIdEdit:SetScript("OnEditFocusGained", function()
        itemIdCaptureArmed = true
    end)

    local addButton = CreateButton(panel, L.ADD, 80)
    addButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 545, -205)
    addButton:SetScript("OnClick", SaveItemFromInputs)

    local clearButton = CreateButton(panel, L.CLEAR, 70)
    clearButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 545, -234)
    clearButton:SetScript("OnClick", ResetAddItemInputs)

    local itemsTitle = CreateText(panel, L.ITEMS, "GameFontNormal")
    itemsTitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -252)

    local activeHeader = CreateText(panel, L.ACTIVE, "GameFontNormalSmall")
    activeHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -278)
    local itemHeader = CreateText(panel, L.ITEM, "GameFontNormalSmall")
    itemHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", 58, -278)
    local maxHeader = CreateText(panel, L.MAX_PER_VISIT_SHORT, "GameFontNormalSmall")
    maxHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", 291, -278)
    local keepHeader = CreateText(panel, L.KEEP_QTY_SHORT, "GameFontNormalSmall")
    keepHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", 376, -278)
    local priceHeader = CreateText(panel, L.MAX_UNIT_PRICE_SHORT, "GameFontNormalSmall")
    priceHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", 461, -278)

    panel.emptyText = CreateText(panel, L.NO_ITEMS, "GameFontDisableSmall")
    panel.emptyText:SetPoint("TOPLEFT", panel, "TOPLEFT", 18, -304)

    for index = 1, 8 do
        local row = CreateItemRow(panel, index)
        row:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -296 - ((index - 1) * 28))
        row:Hide()
    end

    panel:SetScript("OnShow", function()
        Snap:RefreshOptions(true)
    end)

    optionsPanel = panel
    HookItemLinkInsertion()
    self:RefreshOptions(true)
    return panel
end

function Snap:RegisterInterfaceOptions()
    self:CreateOptionsPanel()

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(optionsPanel, optionsPanel.name)
        Settings.RegisterAddOnCategory(category)
        settingsCategory = category
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(optionsPanel)
    end
end

function Snap:OpenInterfaceOptions()
    self:CreateOptionsPanel()
    self:RefreshOptions(true)

    if Settings and Settings.OpenToCategory and settingsCategory then
        Settings.OpenToCategory(settingsCategory.ID or settingsCategory)
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(optionsPanel)
        InterfaceOptionsFrame_OpenToCategory(optionsPanel)
    end
end

function Snap:OpenOptions()
    self:CreateOptionsPanel()
    self:RefreshOptions(true)

    if not standaloneWindow then
        local ok, window = pcall(CreateFrame, "Frame", "SNAPStandaloneOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
        if not ok or not window then
            window = CreateFrame("Frame", "SNAPStandaloneOptionsFrame", UIParent)
        end

        window:SetSize(920, 560)
        window:SetPoint("CENTER")
        window:SetFrameStrata("FULLSCREEN_DIALOG")
        window:SetToplevel(true)
        window:EnableMouse(true)
        window:SetMovable(true)
        window:RegisterForDrag("LeftButton")
        window:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        window:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
        end)
        window:SetScript("OnShow", function()
            Snap:RefreshOptions(true)
        end)
        window:Hide()

        if UISpecialFrames then
            UISpecialFrames[#UISpecialFrames + 1] = "SNAPStandaloneOptionsFrame"
        end

        local title = CreateText(window, L.TITLE, "GameFontHighlight")
        title:SetPoint("TOP", window, "TOP", 0, -6)

        local content = CreateFrame("Frame", nil, window)
        content:SetPoint("TOPLEFT", window, "TOPLEFT", 16, -32)
        content:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -16, 16)
        window.content = content

        standaloneWindow = window
    end

    optionsPanel:SetParent(standaloneWindow.content)
    optionsPanel:ClearAllPoints()
    optionsPanel:SetPoint("TOPLEFT", standaloneWindow.content, "TOPLEFT", 0, 0)
    optionsPanel:SetPoint("BOTTOMRIGHT", standaloneWindow.content, "BOTTOMRIGHT", 0, 0)
    optionsPanel:Show()

    standaloneWindow:Show()
    standaloneWindow:Raise()
    self:RefreshOptions(true)
end

local function PrintHelp()
    Print(L.HELP_HEADER)
    Print(L.HELP_CONFIG)
    Print(L.HELP_ON)
    Print(L.HELP_OFF)
    Print(L.HELP_TEST)
    Print(L.HELP_DEBUG)
    Print(L.HELP_SCAN)
    Print(L.HELP_ADD)
    Print(L.HELP_REMOVE)
    Print(L.HELP_LIST)
    Print(L.HELP_STATUS)
end

local function BoolText(value)
    return value and L.ON or L.OFF
end

local function PrintStatus()
    Print(L.STATUS .. ": " .. (db.enabled and L.ENABLED or L.DISABLED))
    Print(L.TEST_MODE .. ": " .. BoolText(db.testMode) .. " / " .. L.CHAT_MESSAGES .. ": " .. BoolText(db.chat) .. " / " .. L.DEBUG .. ": " .. BoolText(db.debug))
    Print(L.MAX_SPEND .. ": " .. FormatMoney(db.maxSpend) .. " / " .. L.RESERVE_GOLD .. ": " .. FormatMoney(db.reserveGold))
end

local function PrintList()
    local items = GetSortedItems()
    if #items == 0 then
        Print(L.NO_ITEMS)
        return
    end

    for _, item in ipairs(items) do
        Print(string.format("%s #%d - %s, max %d, keep %d, unit <= %s",
            item.enabled and COLORS.green .. L.ON .. COLORS.reset or COLORS.red .. L.OFF .. COLORS.reset,
            item.itemID,
            GetItemName(item.itemID),
            item.maxPerVisit or 0,
            item.keepQty or 0,
            item.maxUnitPrice and item.maxUnitPrice > 0 and FormatMoney(item.maxUnitPrice) or "-"
        ))
    end
end

local function SlashHandler(message)
    EnsureDb()
    local raw = Trim(message)
    local normalized = string.lower(raw)
    local command, rest = normalized:match("^(%S+)%s*(.*)$")
    command = command or ""
    rest = rest or ""

    if command == "" or command == "config" or command == "options" then
        Snap:OpenOptions()
    elseif command == "help" then
        PrintHelp()
    elseif command == "on" or command == "enable" then
        db.enabled = true
        Print(L.ENABLED)
        Snap:RefreshOptions()
    elseif command == "off" or command == "disable" then
        db.enabled = false
        Print(L.DISABLED)
        Snap:RefreshOptions()
    elseif command == "test" then
        db.testMode = not db.testMode
        Print(L.TEST_MODE .. ": " .. BoolText(db.testMode))
        Snap:RefreshOptions()
    elseif command == "debug" then
        db.debug = not db.debug
        Print(db.debug and L.DEBUG_ON or L.DEBUG_OFF)
    elseif command == "scan" then
        Snap:ScanMerchant()
    elseif command == "status" then
        PrintStatus()
    elseif command == "list" then
        PrintList()
    elseif command == "remove" or command == "delete" then
        RemoveItem(ExtractItemID(rest))
    elseif command == "add" then
        local itemText, amountText = raw:match("^%S+%s+(.+)%s+(%d+)%s*$")
        if not itemText then
            itemText = raw:match("^%S+%s+(.+)$")
        end
        AddItem(ExtractItemID(itemText), tonumber(amountText) or 1, 0, 0)
    else
        PrintHelp()
    end
end

function Snap:ADDON_LOADED(addonName)
    if addonName ~= ADDON_NAME then
        HookItemLinkInsertion()
        return
    end

    EnsureDb()
    HookItemLinkInsertion()
    SLASH_SNAP1 = "/snap"
    SlashCmdList.SNAP = SlashHandler
end

function Snap:PLAYER_LOGIN()
    EnsureDb()
    self:RegisterInterfaceOptions()
    HookItemLinkInsertion()
    if db.chat then
        Print(L.LOADED)
    end
end

function Snap:MERCHANT_SHOW()
    self:StartVisit()
end

function Snap:MERCHANT_UPDATE()
    if matchedThisVisit then
        return
    end
    self:QueueScan(0.05)
end

function Snap:GET_ITEM_INFO_RECEIVED()
    self:RefreshOptions()
end

Snap:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

Snap:RegisterEvent("ADDON_LOADED")
Snap:RegisterEvent("PLAYER_LOGIN")
Snap:RegisterEvent("MERCHANT_SHOW")
Snap:RegisterEvent("MERCHANT_UPDATE")
Snap:RegisterEvent("GET_ITEM_INFO_RECEIVED")
