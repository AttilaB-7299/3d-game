(function () {
    let exportAction;

    Plugin.register('split_gltf_exporter_and_fixer', {
        title: 'Split glTF Parts Exporter (Force Separate Meshes)',
        author: 'Blockbench Creator',
        description: 'Forces separate meshes per body part while preserving animations.',
        icon: 'icon-format-gltf',
        version: '5.3.0',
        variant: 'both',

        onload() {
            exportAction = new Action('export_split_gltf_parts_v53', {
                name: 'Export Split glTF Parts (Force Separate Meshes)',
                icon: 'icon-format-gltf',
                category: 'export',
                click() {
                    exportSplitPartsAdvanced();
                }
            });
            MenuBar.addAction(exportAction, 'file.export');
        },

        onunload() {
            if (exportAction) exportAction.delete();
        }
    });

    const PART_MATCHERS = {
        head:      ['head', 'helmet', 'hat'],
        body:      ['body', 'chest', 'torso', 'upperbody', 'upper_body'],
        left_arm:  ['left_arm', 'arm_left', 'arm left', 'leftarm', 'armleft'],
        right_arm: ['right_arm', 'arm_right', 'arm right', 'rightarm', 'armright'],
        left_leg:  ['left_leg', 'leg_left', 'leg left', 'leftleg', 'legleft'],
        right_leg: ['right_leg', 'leg_right', 'leg right', 'rightleg', 'legright']
    };

    function nameMatchesPart(name, partKey) {
        if (!name) return false;
        const n = name.toLowerCase().replace(/\s+/g, '_');
        return PART_MATCHERS[partKey].some(m => n.includes(m.replace(/\s+/g, '_')));
    }

    function elementBelongsToPart(el, partKey) {
        let current = el;
        while (current) {
            if (current.name && nameMatchesPart(current.name, partKey)) {
                return true;
            }
            current = current.parent;
        }
        return false;
    }

    async function exportSplitPartsAdvanced() {
        if (!Project) {
            Blockbench.showQuickMessage('No active model open!', 2000);
            return;
        }

        const gltfCodec = Codecs.gltf || Codecs.glb;
        if (!gltfCodec) {
            Blockbench.showQuickMessage('glTF Exporter Codec not found.', 2000);
            return;
        }

        const dirPath = Blockbench.pickDirectory({
            title: 'Select folder to export split glTF parts',
            resource_id: 'split_gltf_export'
        });
        if (!dirPath) {
            Blockbench.showQuickMessage('Export cancelled.', 1500);
            return;
        }

        const baseName = (Project.name || 'model').replace(/[\\/:*?"<>|]/g, '_');
        let successCount = 0;
        const partKeys = Object.keys(PART_MATCHERS);

        // Keep a full backup of all elements so we can restore perfectly
        const allElements = [...Outliner.elements];

        for (const partKey of partKeys) {
            Blockbench.showQuickMessage(`Exporting ${partKey}...`, 1200);

            // Remove every cube that does NOT belong to this part
            const toRemove = [];
            Outliner.elements.forEach(el => {
                if (!elementBelongsToPart(el, partKey)) {
                    toRemove.push(el);
                }
            });

            toRemove.forEach(el => {
                el.remove();          // temporarily remove from the model
            });

            Canvas.updateView({ elements: true, groups: true });

            // Compile
            let compiled;
            try {
                compiled = await gltfCodec.compile({
                    animations: true,
                    export_animations: true,
                    include_animations: true,
                    encoding: 'gltf'
                });
            } catch (err) {
                console.error(`Compile failed for ${partKey}:`, err);
                // Restore before continuing
                toRemove.forEach(el => {
                    // re-add them
                    if (el.parent) {
                        el.parent.add(el);
                    } else {
                        Outliner.root.add(el);
                    }
                });
                Canvas.updateView({ elements: true, groups: true });
                continue;
            }

            // Restore the removed elements
            toRemove.forEach(el => {
                if (el.parent) {
                    el.parent.add(el);
                } else {
                    Outliner.root.add(el);
                }
            });
            Canvas.updateView({ elements: true, groups: true });

            // Parse result
            let gltfJson;
            if (typeof compiled === 'string') {
                try {
                    gltfJson = JSON.parse(compiled);
                } catch (e) {
                    console.error('JSON parse failed for', partKey);
                    continue;
                }
            } else {
                gltfJson = compiled;
            }

            const animCount = (gltfJson.animations && gltfJson.animations.length) || 0;
            const meshNodes = gltfJson.nodes ? gltfJson.nodes.filter(n => n.mesh !== undefined).length : 0;
            console.log(`[Split glTF] ${partKey}: ${meshNodes} mesh node(s), ${animCount} animations`);

            // Write file
            const extension = gltfCodec.extension || 'gltf';
            const fullPath = `${dirPath}/${baseName}_${partKey}.${extension}`;

            try {
                Blockbench.writeFile(fullPath, {
                    content: JSON.stringify(gltfJson, null, 2),
                    custom_writer: null
                }, () => {});
                successCount++;
                console.log(`[Split glTF] Wrote ${fullPath}`);
            } catch (err) {
                console.error(`Write failed for ${partKey}:`, err);
            }
        }

        Blockbench.showQuickMessage(`Exported ${successCount} parts.`, 4000);
    }
})();
