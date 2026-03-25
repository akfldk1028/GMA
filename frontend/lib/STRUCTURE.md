# lib/ 폴더 구조

```
lib/
├── main.dart
├── app.dart
│
├── common_widgets/
│   ├── app_shell.dart
│   ├── app_sidebar.dart
│   ├── color_dot.dart
│   ├── responsive.dart
│   └── sidebar_item.dart
│
├── constants/
│   ├── app_colors.dart
│   ├── app_theme.dart
│   └── marker_colors.dart
│
├── routing/
│   ├── app_router.dart
│   └── app_router.g.dart
│
├── utils/
│   ├── file_system_provider.dart
│   ├── file_system_provider.g.dart
│   ├── frontmatter_parser.dart
│   ├── note_storage_service.dart
│   └── note_storage_service.g.dart
│
└── features/
    │
    ├── ai_assistant/
    │   ├── models/
    │   │   ├── chat_message_model.dart
    │   │   ├── chat_message_model.freezed.dart
    │   │   └── chat_message_model.g.dart
    │   └── pages/
    │       ├── providers/
    │       │   ├── ai_chat_provider.dart
    │       │   └── ai_chat_provider.g.dart
    │       └── widgets/
    │           └── ai_chat_panel.dart
    │
    ├── content_bridge/
    │   └── stroke_render_service.dart
    │
    ├── dashboard/
    │   └── pages/
    │       ├── screens/
    │       │   └── dashboard_screen.dart
    │       └── widgets/
    │           ├── dashboard_right_panel.dart
    │           ├── document_card.dart
    │           ├── note_tree_section.dart
    │           └── recent_scraps_section.dart
    │
    ├── file_manager/
    │   ├── models/
    │   │   ├── note_metadata_model.dart
    │   │   ├── note_metadata_model.freezed.dart
    │   │   └── note_metadata_model.g.dart
    │   └── pages/
    │       ├── providers/
    │       │   ├── file_manager_provider.dart
    │       │   ├── file_manager_provider.g.dart
    │       │   ├── note_list_provider.dart
    │       │   └── note_list_provider.g.dart
    │       ├── screens/
    │       │   └── file_browser_screen.dart
    │       └── widgets/
    │           ├── file_tree_widget.dart
    │           ├── note_create_dialog.dart
    │           └── note_list_item.dart
    │
    ├── gma_md/
    │   ├── block_registry.dart
    │   ├── gma_md.dart
    │   ├── gma_md_extension.dart
    │   ├── blocks/
    │   │   ├── _block_base.dart
    │   │   ├── callout_block.dart
    │   │   ├── compare_block.dart
    │   │   ├── concept_block.dart
    │   │   ├── example_block.dart
    │   │   ├── flow_block.dart
    │   │   ├── graph_block.dart
    │   │   ├── inner_markdown_content.dart
    │   │   ├── mindmap_block.dart
    │   │   ├── proof_block.dart
    │   │   ├── scrapnote_block.dart
    │   │   ├── summary_block.dart
    │   │   ├── theorem_block.dart
    │   │   └── timeline_block.dart
    │   ├── models/
    │   │   ├── block_definition.dart
    │   │   ├── container_block.dart
    │   │   ├── flow_graph_model.dart
    │   │   ├── mindmap_model.dart
    │   │   └── timeline_model.dart
    │   ├── parser/
    │   │   ├── container_block_parser.dart
    │   │   ├── flow_parser.dart
    │   │   ├── mindmap_parser.dart
    │   │   └── timeline_parser.dart
    │   ├── renderer/
    │   │   ├── flow_canvas_painter.dart
    │   │   ├── graph_canvas_painter.dart
    │   │   └── mindmap_canvas_painter.dart
    │   ├── stubs/
    │   │   └── element_stubs.dart
    │   ├── unwrap/
    │   │   └── md_unwrapper.dart
    │   ├── utils/
    │   │   └── block_templates.dart
    │   └── widgets/
    │       ├── block_insert_menu.dart
    │       └── element_card.dart
    │
    ├── home/
    │   ├── models/
    │   │   ├── folder_model.dart
    │   │   ├── folder_model.freezed.dart
    │   │   └── folder_model.g.dart
    │   ├── pages/
    │   │   ├── screens/
    │   │   │   └── home_screen.dart
    │   │   └── widgets/
    │   │       ├── folder_chip_bar.dart
    │   │       ├── folder_create_dialog.dart
    │   │       ├── folder_picker_dialog.dart
    │   │       ├── folder_tree_widget.dart
    │   │       ├── folders_view.dart
    │   │       ├── home_expanded_sidebar.dart
    │   │       ├── home_icon_rail.dart
    │   │       ├── home_top_bar.dart
    │   │       ├── multi_select_bottom_bar.dart
    │   │       ├── note_card.dart
    │   │       ├── note_grid_view.dart
    │   │       ├── note_list_view.dart
    │   │       ├── overflow_menu.dart
    │   │       ├── pdf_link_popup.dart
    │   │       ├── search_overlay.dart
    │   │       ├── sort_bar.dart
    │   │       └── trash_view.dart
    │   └── providers/
    │       ├── folder_store.dart
    │       ├── folder_store.g.dart
    │       ├── home_note_list_provider.dart
    │       ├── home_note_list_provider.g.dart
    │       ├── home_state_provider.dart
    │       └── home_state_provider.g.dart
    │
    ├── knowledge_graph/
    │   ├── models/
    │   │   └── knowledge_graph_model.dart
    │   ├── pages/
    │   │   ├── providers/
    │   │   │   ├── knowledge_graph_provider.dart
    │   │   │   └── knowledge_graph_provider.g.dart
    │   │   ├── screens/
    │   │   │   └── knowledge_graph_screen.dart
    │   │   └── widgets/
    │   │       ├── graph_canvas.dart
    │   │       ├── graph_controls_bar.dart
    │   │       ├── graph_edge_painter.dart
    │   │       └── graph_node_widget.dart
    │   └── utils/
    │       └── force_directed_layout.dart
    │
    ├── note_editor/
    │   ├── models/
    │   │   ├── frontmatter_model.dart
    │   │   ├── frontmatter_model.freezed.dart
    │   │   ├── frontmatter_model.g.dart
    │   │   ├── marker_model.dart
    │   │   ├── marker_model.freezed.dart
    │   │   ├── marker_model.g.dart
    │   │   ├── note_model.dart
    │   │   ├── note_model.freezed.dart
    │   │   └── note_model.g.dart
    │   ├── pages/
    │   │   ├── providers/
    │   │   │   ├── note_editor_provider.dart
    │   │   │   ├── note_editor_provider.g.dart
    │   │   │   ├── note_provider.dart
    │   │   │   └── note_provider.g.dart
    │   │   ├── screens/
    │   │   │   └── note_editor_screen.dart
    │   │   └── widgets/
    │   │       ├── frontmatter_header.dart
    │   │       └── marker_line_widget.dart
    │   └── utils/
    │       ├── latex_renderer.dart
    │       ├── markdown_config.dart
    │       ├── markdown_extension.dart
    │       ├── marker_line_renderer.dart
    │       ├── marker_parser.dart
    │       └── wiki_link_renderer.dart
    │
    ├── ocr/
    │   ├── ocr_backend.dart
    │   ├── ocr_registry.dart
    │   ├── ocr_service.dart
    │   ├── backends/
    │   │   └── ollama_backend.dart
    │   └── pages/
    │       └── providers/
    │           ├── ocr_provider.dart
    │           └── ocr_provider.g.dart
    │
    ├── pdf_structure/
    │   ├── models/
    │   │   └── pdf_structure_model.dart
    │   ├── providers/
    │   │   ├── pdf_structure_provider.dart
    │   │   └── pdf_structure_provider.g.dart
    │   ├── services/
    │   │   ├── pdf_structure_service.dart
    │   │   └── pdf_to_markdown_service.dart
    │   └── widgets/
    │       ├── heading_tree_widget.dart
    │       └── structure_overlay.dart
    │
    ├── pdf_viewer/
    │   ├── capture/
    │   │   ├── pages/
    │   │   │   ├── providers/
    │   │   │   │   ├── capture_provider.dart
    │   │   │   │   ├── capture_provider.g.dart
    │   │   │   │   ├── lasso_provider.dart
    │   │   │   │   └── lasso_provider.g.dart
    │   │   │   └── widgets/
    │   │   │       ├── capture_overlay.dart
    │   │   │       └── lasso_overlay.dart
    │   │   └── utils/
    │   │       ├── capture_service.dart
    │   │       └── lasso_capture_service.dart
    │   ├── drawing/
    │   │   ├── models/
    │   │   │   ├── drawing_model.dart
    │   │   │   ├── drawing_model.freezed.dart
    │   │   │   └── drawing_model.g.dart
    │   │   ├── pages/
    │   │   │   ├── providers/
    │   │   │   │   ├── drawing_provider.dart
    │   │   │   │   └── drawing_provider.g.dart
    │   │   │   └── widgets/
    │   │   │       ├── drawing_canvas.dart
    │   │   │       ├── drawing_overlay.dart
    │   │   │       ├── drawing_toolbar.dart
    │   │   │       ├── drawing_toolbar_widgets.dart
    │   │   │       └── stroke_painter.dart
    │   │   ├── tools/
    │   │   │   ├── drawing_tool_handler.dart
    │   │   │   ├── eraser_tool.dart
    │   │   │   ├── highlighter_tool.dart
    │   │   │   ├── pen_tool.dart
    │   │   │   └── tool_registry.dart
    │   │   └── utils/
    │   │       └── drawing_serializer.dart
    │   ├── pages/
    │   │   ├── providers/
    │   │   │   ├── pdf_document_provider.dart
    │   │   │   ├── pdf_document_provider.g.dart
    │   │   │   ├── pdf_marker_provider.dart
    │   │   │   └── pdf_marker_provider.g.dart
    │   │   ├── screens/
    │   │   │   └── pdf_viewer_screen.dart
    │   │   └── widgets/
    │   │       ├── capture_highlight_overlay.dart
    │   │       ├── marker_overlay_widget.dart
    │   │       ├── marker_pills_strip.dart
    │   │       └── pdf_page_overlay.dart
    │   └── utils/
    │       └── pdf_text_extractor.dart
    │
    ├── scrapnote/
    │   ├── models/
    │   │   ├── element_model.dart
    │   │   ├── element_model.freezed.dart
    │   │   ├── element_model.g.dart
    │   │   ├── pdf_registry.dart
    │   │   ├── pdf_registry.freezed.dart
    │   │   ├── pdf_registry.g.dart
    │   │   ├── scrapnote_canvas_model.dart
    │   │   ├── scrapnote_canvas_model.freezed.dart
    │   │   ├── scrapnote_canvas_model.g.dart
    │   │   ├── scrapnote_page_model.dart
    │   │   ├── scrapnote_page_model.freezed.dart
    │   │   └── scrapnote_page_model.g.dart
    │   ├── pages/
    │   │   ├── providers/
    │   │   │   ├── scrapnote_canvas_provider.dart
    │   │   │   └── scrapnote_canvas_provider.g.dart
    │   │   ├── screens/
    │   │   │   └── scrapnote_screen.dart
    │   │   └── widgets/
    │   │       ├── capture_element_widget.dart
    │   │       ├── confirm_scrap_popup.dart
    │   │       ├── element_navigator_drawer.dart
    │   │       ├── highlight_card_widget.dart
    │   │       └── scrapnote_canvas.dart
    │   ├── providers/
    │   │   ├── element_store.dart
    │   │   ├── element_store.g.dart
    │   │   ├── note_scrap_provider.dart
    │   │   ├── note_scrap_provider.g.dart
    │   │   ├── pdf_registry_provider.dart
    │   │   ├── pdf_registry_provider.g.dart
    │   │   ├── scrap_annotation_provider.dart
    │   │   ├── scrap_annotation_provider.g.dart
    │   │   ├── scrap_insertion_provider.dart
    │   │   ├── scrap_insertion_provider.g.dart
    │   │   ├── scrapnote_page_store.dart
    │   │   ├── scrapnote_page_store.g.dart
    │   │   ├── scrapnote_provider.dart
    │   │   ├── scrapnote_provider.g.dart
    │   │   ├── scrapnote_service_provider.dart
    │   │   └── scrapnote_service_provider.g.dart
    │   ├── services/
    │   │   ├── scrap_insertion_service.dart
    │   │   └── scrapnote_service.dart
    │   ├── utils/
    │   │   ├── element_ref_parser.dart
    │   │   ├── scrapnote_block_editor.dart
    │   │   └── scrapnote_serializer.dart
    │   └── widgets/
    │       └── pdf_region_image.dart
    │
    ├── scraps_library/
    │   └── pages/
    │       ├── providers/
    │       │   ├── scraps_filter_provider.dart
    │       │   └── scraps_filter_provider.g.dart
    │       ├── screens/
    │       │   └── scraps_library_screen.dart
    │       └── widgets/
    │           ├── scrap_card.dart
    │           └── scrap_filter_tabs.dart
    │
    ├── settings/
    │   └── pages/
    │       └── screens/
    │           └── settings_screen.dart
    │
    ├── splash/
    │   └── pages/
    │       └── screens/
    │           └── splash_screen.dart
    │
    └── workspace/
        ├── models/
        │   ├── pdf_marker_model.dart
        │   ├── pdf_marker_model.freezed.dart
        │   ├── pdf_marker_model.g.dart
        │   ├── workspace_state.dart
        │   ├── workspace_state.freezed.dart
        │   ├── workspace_state.g.dart
        │   ├── workspace_state_model.dart
        │   ├── workspace_state_model.freezed.dart
        │   └── workspace_state_model.g.dart
        ├── pages/
        │   ├── providers/
        │   │   ├── theme_provider.dart
        │   │   ├── theme_provider.g.dart
        │   │   ├── workspace_provider.dart
        │   │   └── workspace_provider.g.dart
        │   ├── screens/
        │   │   └── workspace_screen.dart
        │   └── widgets/
        │       ├── canvas/
        │       │   ├── canvas_card.dart
        │       │   ├── canvas_handles.dart
        │       │   ├── canvas_header.dart
        │       │   ├── canvas_painters.dart
        │       │   ├── group_edit_dialog.dart
        │       │   └── scrap_import_dialog.dart
        │       ├── file_browser_drawer.dart
        │       ├── live_scraps_panel.dart
        │       ├── marker_edit_modal.dart
        │       ├── note_editor_modal.dart
        │       ├── page_thumbnails_panel.dart
        │       ├── pdf_tab_bar.dart
        │       ├── scrap_board_popup.dart
        │       ├── scrap_card_panel.dart
        │       ├── scrap_thumbnails_sidebar.dart
        │       ├── scrapnote_panel.dart
        │       ├── sticky_note_widget.dart
        │       ├── workspace_canvas_panel.dart
        │       ├── workspace_header_v3.dart
        │       ├── workspace_kebab_menu.dart
        │       └── workspace_unified_header.dart
        └── services/
            └── workspace_persistence.dart
```
