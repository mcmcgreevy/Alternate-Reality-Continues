# S05 — Canonical map limits for colonnade faces

2026-11-27. Research only. This pass compares the 125 same-threshold differences whose candidate boundary is14 with the unchanged canonical Kroah map. It does not change gameplay or assume the candidate is byte-identical to Kroah's executable.

## Results

- All 125 faces were sampled and grouped into eight exact pixel-strip patterns. The [representative contact sheet](s05/colonnade-patterns.png) shows one canonical crop per pattern, labeled with count and approach coordinate/direction.
- For 99 faces, the opposite candidate face is13. The same physical boundary's image strip therefore serves candidate 14 on one side and13 on the other. Exact comparison against all candidate 13 face strips finds a match for each of these 99 faces.
- The remaining 26 faces have opposite candidate values14 (22 faces),6 (2),0 (1) and3 (1). Their strips do not exactly match candidate 13 strips in this sampling. That is not proof that a particular symbol means colonnade, one-way passage or openness.
- All 125 now have canonical-image status **not_resolved_by_image** in both the current face audit and candidate comparison. They are examined-but-unresolved, not verified matches. The other 16259 face rows retain their prior statuses; this pass does not reclassify them.

The 99 shared-boundary cases are particularly important: these are not 99 independent confirmations from other locations. An approach and its reverse can sample the very same line in a two-dimensional map. Candidate data and the decoded first-person artwork distinguish the two sides, but this raster comparison does not establish that the map separately depicts each side's appearance.

## Method and reproducibility

For every target face, sample 30 RGB pixels: ten positions along the middle of the boundary (cell-relative tangent 3..12), at three perpendicular positions (-1,0,+1) around the grid boundary. Each cell is 16 pixels. North/south strips run west-to-east; east/west strips run north-to-south. Exclude corners and cell labels; retain exact colors without fuzzy matching. Out-of-image pixels would be explicitly marked, not fabricated.

[Row-level evidence](s05/colonnade-image-comparison.csv) preserves approach coordinates, current code, full ARGB signature (alpha fixed to FF for RGB comparison), count/example of identical candidate 13 strips, interpretation, and opposite candidate value. The signatures were generated with System.Drawing GetPixel and independently checked against standard-library BMP pixel reads of a temporary local conversion. All 125 agree between the two read paths. Group counts total 125 and the opposite-value distribution independently accounts for all 125.

The conversion/contact sheet is derived analysis; archived Map.png remains unchanged. Representative crops cover 3x3 cells and are enlarged twofold. These images are context for a narrow strip comparison, not complete cell-level semantic proof. The full original map hash remains `6f90a1f6ad1da0dabb53b5242f3e112c52dc66f9d273fb684208ae732c8af835`.

## Consequence for S05

Do not spend further review treating an identical shared raster line as a new directional proof. For these125 faces, historical first-person appearance and movement must be reconciled using the candidate data/routines, other same-edition evidence or an explicit bounded adaptation decision. The previously decoded candidate 14 colonnade artwork is strong candidate evidence; it does not make every map pixel a fidelity pass.

S05's classification requirement permits an explicit unresolved-image disposition, but material unresolved behavior still blocks historical-verification claims. This pass advances coverage, not story closure. Remaining face groups, the existing proposed correction scope, save migration and acceptance remain separate tasks.
