# Atmosphere study 01

Direction approved 2026-11-10: grounded, inhabited fantasy with an uncanny undertone. This first playable visual study focuses on the tavern screen and Dungeon corridor, rather than reproducing Atari/C64 pixel art.

- Tavern: original AI-generated painted interior, composed with quiet space behind the menu and the innkeeper visible at the right. It is a location backdrop, not a navigable room or recovered historical asset. Music and timed lyrics continue normally.
- Dungeon: deterministic 256×256 procedural stone/timber surfaces with normal maps and mipmaps, cool ambient light, warm shadow-casting torches, iron door straps and shallow masonry trim. Secret walls retain the same treatment as ordinary stone. Decorations do not alter collision or raw map codes.
- Interface: world view grows from 750×420 to 854×480; the internal 3D render increases from 375×210 to 1024×576 with linear filtering and 2× MSAA. Compact side panels, subdued borders and a translucent tavern menu give the scene more room.

Controls, save format, movement, doors, transition data, service prices and lyrics are unchanged. Materials also improve the City incidentally; distinctive City architecture and signs remain a later art pass. These surfaces and fixtures are still an art-direction prototype, not finished environment assets.

## Asset provenance

assets/art/tavern-painted-v1.png was generated with the built-in image-generation tool on 2026-11-10. No original game image was supplied. Brief: original wide illustrated tavern; seated guest's view at an aged oak counter; quiet dark left side for menu; believable middle-aged innkeeper in linen and green waistcoat at right; amber candles/hearth, cool dusk through leaded glass; weathered wood/plaster, restrained palette, no text/UI/logos. The generated image was copied into the project unchanged. It is decorative art and does not depict a historical person or establish game lore.

scripts/atmosphere_materials.gd creates the original procedural textures at startup. The legacy prototype scene keeps its previous materials and rendering settings for comparison.

## Review

Launch Play.cmd and inspect the tavern menu, food menu, confirmation and lyrics. Walk to the Dungeon entrance to compare its stone, torch and door. Tab still shows the map. Existing screenshots are refreshed by the original-route capture test; the previous appearance remains in Git history at f3c9535.

The increased render resolution, antialiasing and torch shadows cost more GPU time. Tested with Godot 4.5.1's OpenGL compatibility renderer on this machine; lower-end GPU performance remains to be evaluated. Full-floor and original-route integration tests cover the streamed renderer and gameplay. No performance target is claimed yet.

## City sky and interior follow-up

City streets now use a procedural sky with clouds, a sun, twilight colors and stars. Its appearance, cloud displacement, ambient light and sunlight follow the saved world minute, not the computer clock. Standing still does not advance weather; waiting, travelling and loading a save update it. The fixed 24-hour cycle repeats daily, with sunrise near 06:00 and sunset near 18:00. These are original presentation choices, not reconstructed astronomical/weather rules. There is no rain or gameplay weather effect yet.

Dungeon cells and City building/secret-passage cells receive ceilings. City classification uses ARX location descriptions: secret passage (7), establishments (16–59, 65–66, 68–89) are covered; streets, alleys, yards, gates and arena/palace grounds remain open. The wider City's classification is provisional. It does not infer roofs merely because a space has surrounding walls. Open doorways may reveal sky beyond the roofed cell. The tavern still uses its painted indoor screen.

Outdoor boundary walls use a lower visual profile and the camera has a modest upward pitch/wider field of view so sky is visible between walls. Indoor camera framing stays unchanged. Raw directional boundaries, movement and transitions are untouched. Day/night lighting updates do not rebuild geometry. Test tests/test_city_environment.gd checks classification, roof generation, noon/night, waiting, save restoration, daily rollover and return indoors; -- --capture produces the City sky screenshots.

Implementation reference: [Godot sky shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/sky_shader.html). Sky shader and classification are project-authored code, not original game assets.
