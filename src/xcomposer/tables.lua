local tables = {}

local char_and_dead_keysym = {
  {'`', 'dead_grave'},
  {'´', 'dead_acute'},
  {'^', 'dead_circumflex'},
  {'~', 'dead_tilde'},
  -- {'', 'dead_perispomeni'},        -- U+0342 COMBINING GREEK PERISPOMENI
  {'¯', 'dead_macron'},
  {'˘', 'dead_breve'},
  {'˙', 'dead_abovedot'},
  {'¨', 'dead_diaeresis'},
  {'˚', 'dead_abovering'},
  {'˝', 'dead_doubleacute'},
  {'ˇ', 'dead_caron'},
  {'¸', 'dead_cedilla'},
  {'˛', 'dead_ogonek'},
  -- {'', 'dead_iota'},               -- U+0345 COMBINING GREEK YPOGEGRAMMENI (?)
  -- {'', 'dead_voiced_sound'},       -- U+3099 COMBINING KATAKANA-HIRAGANA VOICED SOUND MARK
  -- {'', 'dead_semivoiced_sound'},゚   -- U+309A COMBINING KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK
  -- {'', 'dead_belowdot'},           -- U+0323 COMBINING DOT BELOW
  -- {'', 'dead_hook'},               -- U+0309 (Above) / U+0321 (Palatized Below) / U+0322 (Palatized Below)
  -- {'', 'dead_horn'},               -- U+031B COMBINING HORN
  -- {'', 'dead_stroke'},             -- Various (?)
  -- {'', 'dead_abovecomma'},         -- U+0313 COMBINING COMMA ABOVE
  -- {'', 'dead_psili'},              -- U+0313           ''
  -- {'', 'dead_abovereversedcomma'}, -- U+0314 COMBINING REVERSED COMMA ABOVE
  -- {'', 'dead_dasia'},              -- U+0341           ''
  -- {'', 'dead_doublegrave'},        -- U+030F COMBINING DOUBLE GRAVE ACCENT
  -- {'', 'dead_belowring'},          -- U+0325 COMBINING RING BELOW
  -- {'', 'dead_belowmacron'},        -- U+0331 COMBINING MACRON BELOW
  -- {'', 'dead_belowcircumflex'},    -- U+032D COMBINING CIRCUMFLEX ACCENT BELOW
  -- {'', 'dead_belowtilde'},         -- U+0330 COMBINING TILDE BELOW
  -- {'', 'dead_belowbreve'},         -- U+032E COMBINING BREVE BELOW
  -- {'', 'dead_belowdiaeresis'},     -- U+0324 COMBINING DIAERESIS BELOW
  -- {'', 'dead_invertedbreve'},      -- U+0311 COMBINING INVERTED BREVE
  -- {'', 'dead_belowcomma'},         -- U+0326 COMBINING COMMA BELOW
  {'¤', 'dead_currency'},
  {'_', 'dead_lowline'},
  -- {'', 'dead_aboveverticalline'},  -- U+030D COMBINING VERTICAL LINE ABOVE
  -- {'', 'dead_belowverticalline'},  -- U+030E COMBINING DOUBLE VERTICAL LINE ABOVE
  -- {'', 'dead_longsolidusoverlay'}, -- U+0338 COMBINING LONG SOLIDUS OVERLAY
  -- {'', 'dead_a'}, -- (?)
  -- {'', 'dead_A'}, -- (?)
  -- {'', 'dead_e'}, -- (?)
  -- {'', 'dead_E'}, -- (?)
  -- {'', 'dead_i'}, -- (?)
  -- {'', 'dead_I'}, -- (?)
  -- {'', 'dead_o'}, -- (?)
  -- {'', 'dead_O'}, -- (?)
  -- {'', 'dead_u'}, -- (?)
  -- {'', 'dead_U'}, -- (?)
  -- {'', 'dead_small_schwa'},   -- (?)
  -- {'', 'dead_capital_schwa'}, -- (?)
  -- {'', 'dead_greek'},
}

tables.dead_keysym_to_char = {}
tables.char_to_dead_keysym = {}
for _, ck in ipairs(char_and_dead_keysym) do
  local c, k = ck[1], ck[2]
  tables.dead_keysym_to_char[k] = c
  tables.char_to_dead_keysym[c] = k
end

return tables
