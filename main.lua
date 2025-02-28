--- STEAMODDED HEADER
--- MOD_NAME: melonade sandbox
--- MOD_ID: melonadesandbox
--- MOD_AUTHOR: [melonade]
--- MOD_DESCRIPTION: a bunch of random stuff for me to learn how to make mods
----------------------------------------------
------------MOD CODE -------------------------

SMODS.Atlas{
    key = "Jokers",
    path = "scribbal.png",
    px = 284,
    py = 380
}

SMODS.Joker{
    name = "Scribbal",
    key = "scribbal",
    loc_txt = {
        name = "Scribbal",
        text = {
            "When blind is selected,",
            "randomly copies one of",
            "your {C:attention}Jokers' abilities{}.",
            "{s:0.75}Currently copying: {C:attention}#1#{}"
        }
    },
    rarity = 3,
    cost = 10,
    atlas = "Jokers",
    pos = {x = 0, y = 0},
    blueprint_compat = true,
    config = { 
        extra = {
            copying = "None",
            indexCopy = nil
        }
    },
    loc_vars = function(self,info_queue,card)
        return { vars = {card.ability.extra.copying, card.ability.extra.indexCopy} }
    end,
    calculate = function(self,card,context)
        if context.setting_blind then
            local jokers = {}
            for i=1, #G.jokers.cards do 
                if G.jokers.cards[i] ~= card and G.jokers.cards[i].config.center.blueprint_compat == true then
                    jokers[#jokers+1] = G.jokers.cards[i]
                    print(G.jokers.cards[i].label)
                end
            end
            
            if #jokers <= 0 then
                return
            end
            
            local chooseRandom = math.random(1,#jokers)

            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == jokers[chooseRandom] then
                    card.ability.extra.indexCopy = i
                end
            end
            card.ability.extra.copying = jokers[chooseRandom].label

            --print(card.ability.extra.instCopy.label)

            return {
                card = card,
                message = "Copied!",
                colour = G.C.MONEY
            }
        end

        if context.ending_shop then
            card.ability.extra.indexCopy = nil
            card.ability.extra.copying = "None"
        end

        local other_joker = G.jokers.cards[card.ability.extra.indexCopy]
        if other_joker and other_joker ~= card then
            context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
            context.blueprint_card = context.blueprint_card or card
            if context.blueprint > #G.jokers.cards + 1 then return end
            local other_joker_ret = other_joker:calculate_joker(context)
            local other_joker_bpc = context.blueprint_card
            context.blueprint = nil
            context.blueprint_card = nil
            if other_joker_ret then 
                other_joker_ret.card = other_joker_bpc or card
                other_joker_ret.colour = G.C.BLUE
                return other_joker_ret
            end
        end
    end,
    update = function(self,card,dt)
        if card.ability.extra.copying ~= "None" then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i].label == card.ability.extra.copying then
                    card.ability.extra.indexCopy = i
                end
            end
        end
    end
}

SMODS.Joker{
    name = "Moral Support",
    key = "moralsupport",
    loc_txt = {
        name = "Moral Support",
        text = {
            "\"melonade wheres the joker that",
            "is just the default joker but with",
            "a {C:green}#4# in #3#{} chance to give {X:mult,C:white}X#2#{} mult\"",
            "{s:0.5}your welcome riel"
        }
    },
    blueprint_compat = true,
    config = {
        extra = {
            normalMult = 4,
            xmult = 100000,
            chance = 1000,
            probability = 1
        }
    },
    loc_vars = function(self,info_queue,card)

        card.ability.extra.probability = G.GAME.probabilities.normal

        return { vars = {
            card.ability.extra.normalMult,
            card.ability.extra.xmult,
            card.ability.extra.chance,
            card.ability.extra.probability
        } }
    end,
    calculate = function(self,card,context)
        if context.joker_main then
            if pseudorandom("moralsupport", card.ability.extra.probability, card.ability.extra.chance) <= card.ability.extra.probability then
                return {
                    card = card,
                    xmult = card.ability.extra.xmult
                }
            else
                return {
                    card = card,
                    mult = card.ability.extra.normalMult
                }
            end
        end
    end
}

SMODS.Atlas{
    key = "chudjokeratlas",
    path = "chudjoker.png",
    px = 71,
    py = 95
}

SMODS.Joker{
    name = "Chudjoker",
    key = "chudjoker",
    loc_txt = {
        name = "Chudjoker",
        text = {
            "All {C:attention}listed{} {C:green}probabilities{}",
            "have a 0% chance",
            "of occurring"
        }
    },
    atlas = "chudjokeratlas",
    pos = {x = 0, y = 0},
    rarity = 2,
    blueprint_compat = false,
    add_to_deck = function(self,card,from_debuff)
        for k, v in pairs(G.GAME.probabilities) do 
            G.GAME.probabilities[k] = v*0
        end
    end,
    remove_from_deck = function(self,card,from_debuff)
        for k, v in pairs(G.GAME.probabilities) do 
            G.GAME.probabilities[k] = 1
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i].label == "Oops! All 6s" then
                    G.GAME.probabilities[k] = G.GAME.probabilities[k] * 2
                end
            end
        end
    end
}

SMODS.Atlas{
    key = "absoluteeverythingatlas",
    path = "absoluteeverything.png",
    px = 71,
    py = 95
}

SMODS.Consumable{
    name = "Absolute Everything",
    key = "absoluteeverything",
    loc_txt = {
        name = "Absolute Everything",
        text = {
            "{C:green}#1# in #2#{} chance to set your",
            "ante to {C:attention}#3#{} and",
            "set your money to {C:money}#4#{}",
            "or set your {C:chips}hand{} size to 0.",
            "{s:0.5}fuck you valor"
        }
    },
    atlas = "absoluteeverythingatlas",
    pos = {x = 0, y = 0},
    cost = 4,
    set = "Tarot",
    config = {
        extra = {
            probability = 1,
            chance = 2,
            setAnte = -520897523890352098532098532098325890325890325890325098325908352,
            setMoney = 2350893520985328905328095320895238903520893528095238903250893529803529083520983529805238905238902358903528903528905329083258905328095328095328093529085238095320893258093528905238093259805239802359803524908235890352980352980352980325980352980352980352908352980352908532908352980253089325
        }
    },
    loc_vars = function(self,info_queue,card)
        card.ability.extra.probability = G.GAME.probabilities.normal

        return { vars = {
            card.ability.extra.probability,
            card.ability.extra.chance,
            card.ability.extra.setAnte,
            card.ability.extra.setMoney
        } }
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self,card,area,copier)
        if pseudorandom("absoluteeverything", card.ability.extra.probability, card.ability.extra.chance) <= card.ability.extra.probability then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                card:juice_up(0.3, 0.5)
                ease_ante(card.ability.extra.setAnte)
                ease_dollars(card.ability.extra.setMoney, true)
                return true end }))
            delay(0.6)
        else
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                card:juice_up(0.3, 0.5)
                G.hand:change_size(-G.hand.config.card_limit)
                return true end }))
            delay(0.6)
        end
    end
}

----------------------------------------------
------------MOD CODE END----------------------