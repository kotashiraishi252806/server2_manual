システムを理解する試み（7/2~)

- AIと静的コード解析するにあたって。
    
    私は開発初心者です。現在あるtest.phpの挙動を理解したいため、以下のルールで静的解析の解説をしてください。網羅的な説明や、処理の流れとデータの流れが混ざった解説は混乱するため禁止します。
    
    1. 【概要】このシステムが全体として「何をするものか」を3行で解説
    2. 【コントロールフロー（処理の流れ）】どの関数からどの関数へ処理が移るのか、実行順序のフローのみを解説（データの話は一切除外）
    3. 【データフロー（データの動き）】具体的にどのタイミングで、どのデータがどこから取得され、どう加工されてどこへ出力（帰還）されるのか、データに特化して解説
    
    まずは1の概要から説明してください。私が「次（コントロールフロー）をお願いします」と言うまで、2と3の詳細は書かないでください。
    
    【追加の要望】
    Notionにそのまま貼り付けて図表化できるよう、互換性のある標準的な「Mermaid記法」を使って図解（シーケンス図やフローチャートなど）を出力してください。
    
    【重要：Mermaidの図のデザインに関する絶対ルール】
    今後出力するすべてのMermaidの図（シーケンス図、フローチャート等）は、修士論文や企業の技術仕様書にそのまま掲載できる、フォーマルで洗練されたデザインにしてください。デフォルトのカラフルで幼稚なデザインは禁止します。
    
    具体的には、以下の「ディレクティブ（設定）」を必ずMermaidコードの先頭（1行目）に記述してください。
    
    ▼ フローチャート（graph TDなど）の場合の先頭指定：
    %%{init: {'theme': 'neutral', 'themeVariables': {'primaryColor': '#ffffff', 'edgeColor': '#333333', 'lineColor': '#333333', 'bodyBkg': '#ffffff', 'mainBkg': '#ffffff'}}}%%
    
    ▼ シーケンス図（sequenceDiagram）の場合の先頭指定：
    %%{init: {'theme': 'neutral'}}%%
    
    【デザインの方向性】
    ・背景は白、線や文字は黒〜濃いグレーを基調とした「グレースケール」または「ニュートラル」な配色にすること
    ・無駄なグラデーションや派手な色は一切使わないこと
    ・矢印や枠線は細くスマートに統一すること
    
    このルールを適用した上で、次の「2. コントロールフロー」の解説と図の作成をお願いします。
    
    下記はシーケンス図の作り方一例。コードブロックを追加し、言語をmarianにして、張り付けると下記のようになる
    
- 全体上（簡略概要）
    - 
    
    ```mermaid
    sequenceDiagram
        autonumber
        actor User as ユーザー
        participant Front as 画面 (test.php)
        participant Logic as 処理ロジック
        participant DB as データベース
    
        User->>Front: ボタンをクリック
        Front->>Logic: データの取得要求
        Logic->>DB: SQLでデータ照会
        DB-->>Logic: 検索結果を返却
        Logic-->>Front: データを分かりやすく加工
        Front-->>User: 画面に結果を表示
    ```
    
- コントロールフロー
    
    実行経路は大きく 6本のパス に分類できます。
    
    ---
    
    パス一覧
    
    ①   │ ページ読み込み         │ fetchModels() → (終了) ／ updateGridBtn()
    ②   │ 機種選択               │ fetchLabels() → updateStatusBar() → updateGridBtn()
    ③   │ 矩形表示ボタン         │ onToggleGrid() → fetchHeatmap() + fetchStats()
    ④   │ 地図移動/ズーム        │ [300ms遅延] → fetchHeatmap()
    ⑤   │ 色モード変更           │ updateLegend() → recolorAll() → getColor()
    ⑥   │ SSID解析（表示ボタン） │ executeMode1/2() → recolorAll() + updateLegend() + updatePopups() │
    
    ---
    
    図1：全体コントロールフロー
    
    ```mermaid
    %%{init: {'theme': 'neutral', 'themeVariables': {'primaryColor': '#ffffff', 'edgeColor': '#333333', 'lineColor': '#333333', 'bodyBkg': '#ffffff', 'mainBkg': '#ffffff'}}}%%
    flowchart TD
    subgraph ENTRY["エントリーポイント"]
    E1([ページ読み込み])
    E2([機種選択])
    E3([ラベル・日時変更])
    E4([矩形表示ボタン])
    E5([地図 moveend / zoomend])
    E6([色モード変更])
    E7([透明度・比率変更])
    E8([SSIDフェーズ 次へ])
    E9([SSID 表示ボタン])
    E10([強調解除ボタン])
    E11([map クリック])
    end
    ```
    
    ```mermaid
    %%{init: {'theme': 'neutral', 'themeVariables': {'primaryColor': '#ffffff', 'edgeColor': '#333333', 'lineColor': '#333333', 'bodyBkg': '#ffffff', 'mainBkg': '#ffffff'}}}%%
    flowchart TD
    
    subgraph ENTRY["エントリーポイント"]
        E1([ページ読み込み])
        E2([機種選択])
        E3([ラベル・日時変更])
        E4([矩形表示ボタン])
        E5([地図 moveend / zoomend])
        E6([色モード変更])
        E7([透明度・比率変更])
        E8([SSIDフェーズ 次へ])
        E9([SSID 表示ボタン])
        E10([強調解除ボタン])
        E11([map クリック])
    end
    
    subgraph FETCH["データ取得関数"]
        F1[fetchModels]
        F2[fetchLabels]
        F3[fetchHeatmap]
        F4[fetchStats]
        F5[fetchGlobalSsids]
    end
    
    subgraph PROCESS["処理関数"]
        P1{onToggleGrid}
        P2[clearGrid]
        P3[renderSsidList]
        P4[executeMode1]
        P5[executeMode2]
        P6[clearSsidHighlight]
    end
    
    subgraph UI["UI 更新関数"]
        U1[recolorAll]
        U2[updateLegend]
        U3[updatePopups]
        U4[updateStatusBar]
        U5[updateGridBtn]
        U6[updateSelectedDisplay]
        U7[closeAllPanels]
    end
    
    E1 --> F1
    E1 --> U5
    
    E2 --> F2
    E2 --> U4
    E2 --> U5
    E2 -.->|適用済の場合| F3
    
    E3 --> U4
    E3 --> U5
    
    E4 --> P1
    P1 -->|表示| F3
    P1 -->|表示| F4
    P1 -->|クリア| P2
    
    E5 -->|300ms 遅延| F3
    
    E6 --> U2
    E6 -->|グリッド有| U1
    E6 -->|SSID 解析中| P6
    E6 -.->|SSID モード| F5
    
    E7 --> U2
    E7 --> U1
    E7 -.->|比率変更時| U3
    
    E8 --> P3
    
    E9 -->|モード 1| P4
    E9 -->|モード 2| P5
    
    P4 --> U1
    P4 --> U2
    P4 --> U3
    P4 --> U6
    
    P5 --> U1
    P5 --> U2
    P5 --> U3
    P5 --> U6
    
    P6 --> U1
    P6 --> U2
    P6 --> U3
    P6 --> U6
    
    E10 --> P6
    
    E11 --> U7
    ```
    
    ---
    
    図2：fetchHeatmap() の内部呼び出しチェーン
    
    このシステムの中核であり、最も多くの関数を連鎖的に呼び出す関数です。
    
    ```mermaid
    %%{init: {'theme': 'neutral', 'themeVariables': {'primaryColor': '#ffffff', 'edgeColor': '#333333', 'lineColor': '#333333', 'bodyBkg': '#ffffff', 'mainBkg': '#ffffff'}}}%%
    flowchart TD
    A([fetchHeatmap 開始]) --> B[進行中リクエストを abort]
    B --> C[buildFilterParams]
    C --> D[clearGrid]
    D --> E[APIリクエスト送信]
    E --> F{レスポンス判定}
    F -->|AbortError| Z([終了])
    F -->|success: false| Z
    F -->|success: true| G[currentStep 更新]
    G --> H{step 変わった？}
    H -->|Yes| I[highlightedCells.clear]
    H -->|No| J
    I --> J[L.rectangle を N 個生成 ＋ gridState.set]
    J --> K{highlightedCells 有？}
    K -->|Yes| L[recolorAll]
    K -->|No| M
    L --> M{干渉モード以外？}
    M -->|Yes| N[fetchLegendCounts]
    N --> O[updateLegend]
    M -->|No| O
    O --> Z
    
    ```
    
    ---
    
    「次（データフロー）をお願いします」とお知らせください。
    
    ✻ Worked for 1m 44s
    
- データフロー
    
    API呼び出しと入出力データ一覧
    
    #: ①
    タイミング: ページ読み込み
    リクエストパラメータ（入力）: get_models=1
    レスポンスJSON（出力）: {models:[]}
    格納先: model_select
    ────────────────────────────────────────
    #: ②
    タイミング: 機種選択後
    リクエストパラメータ（入力）: get_labels=1 & model=X
    レスポンスJSON（出力）: {labels:[]}
    格納先: label_select
    ────────────────────────────────────────
    #: ③
    タイミング: 矩形表示ボタン
    リクエストパラメータ（入力）: zoom, min/max_lat/lng, model, label, mode, ...
    レスポンスJSON（出力）: {data:[{grid_key, bounds, d_code, max_security_rank, avg_rssi, scan_cnt,
    p_interf, worst_pair, ...}], step}
    格納先: gridState
    ────────────────────────────────────────
    #: ④
    タイミング: ③の直後
    リクエストパラメータ（入力）: get_legend_counts=1
    レスポンスJSON（出力）: {counts:{ap:[], ssid:[], standard:[], sec_ratio_*:[], ...}}
    格納先: globalLegendCounts
    ────────────────────────────────────────
    #: ⑤
    タイミング: ③と同時
    リクエストパラメータ（入力）: get_stats=1 & model,
    レスポンスJSON（出力）: {scan_count, bssid_count, ssid_count, avg_per_scan, cell_count, first_scan, last_scan}
    格納先: #stats-content（直接描画）
    ────────────────────────────────────────
    #: ⑥
    タイミング: SSIDモード選択時
    リクエストパラメータ（入力）: get_ssids_global=1 &
    レスポンスJSON（出力）: {ssids:[{ssid, cell_count, bssid_count}]}
    格納先: globalSsidData[]
    ────────────────────────────────────────
    #: ⑦
    タイミング: SSID解析 モード1
    リクエストパラメータ（入力）: get_cells_by_ssid=1
    レスポンスJSON（出力）: {cells:[{grid_key, avg_rssi, ssid_ap_cnt, max_standard_code, max_security_rank}]}
    格納先: highlightedCells
    ────────────────────────────────────────
    #: ⑧
    タイミング: SSID解析 モード2
    リクエストパラメータ（入力）: get_cells_by_ssid_co
    レスポンスJSON（出力）: {cells:[{grid_key, match_count, any_bssid_cnt, all_bssid_cnt}]}
    格納先: highlightedCells
    
    ---
    
    ```mermaid
    %%{init: {'theme': 'neutral'}}%%
    sequenceDiagram
    participant B as ブラウザ（test27.php）
    participant P as test27_processor.php
    participant DB as データベース
    Note over B,DB: ① ページ読み込み
    B->>P: GET ?get_models=1
    P->>DB: モデル一覧クエリ
    DB-->>P: モデル名リスト
    P-->>B: { models: ["機種A", ...] }
    B->>B: model_select に挿入
    
    Note over B,DB: ② 機種選択
    B->>P: GET ?get_labels=1 & model=X
    P->>DB: ラベル一覧クエリ
    DB-->>P: ラベルリスト
    P-->>B: { labels: ["label1", ...] }
    B->>B: label_select に挿入
    
    Note over B,DB: ③④⑤ 矩形表示ボタン押下（3本同
    B->>P: GET ?zoom= & min_lat= & max_lat= & min_lng= & max_lng= & model= & label= & mode=
    P->>DB: グリッド集計クエリ
    DB-->>P: グリッドごとの集計
    P-->>B: { data:[{grid_key, bounds, ap_cnt, ...
    B->>B: gridState に格納 → L.rectangle 生成 → 地図描画
    
    B->>P: GET ?get_legend_counts=1 & zoom=
    P-->>B: { counts:{ap:[], ssid:[], ...} }
    B->>B: globalLegendCounts に格納 → 凡例更新
    
    B->>P: GET ?get_stats=1 & model= & label=
    P-->>B: { scan_count, bssid_count, first_scan,
    B->>B: #stats-content に直接描画
    
    Note over B,DB: ⑥ SSID モード選択
    B->>P: GET ?get_ssids_global=1 & model= & labe
    P->>DB: SSIDリストクエリ
    DB-->>P: SSIDリスト
    P-->>B: { ssids:[{ssid, cell_count, bssid_count}] }
    B->>B: globalSsidData[] に格納 → SSIDリスト描
    
    Note over B,DB: ⑦ SSID解析 モード1
    B->>P: GET ?get_cells_by_ssid=1 & ssids=["X"] & step=
    P->>DB: 指定SSID保持グリッドクエリ
    DB-->>P: グリッドごとのSSID統計
    P-->>B: { cells:[{grid_key, avg_rssi, ssid_ap_
    B->>B: highlightedCells に格納 → recolorAll → 再着色
    
    Note over B,DB: ⑧ SSID解析 モード2
    B->>P: GET ?get_cells_by_ssid_combo=1 & ssids=
    P->>DB: 複数SSID共存グリッドクエリ
    DB-->>P: 共存データ
    P-->>B: { cells:[{grid_key, match_count, any_bssid_cnt, all_bssid_cnt}] }
    B->>B: highlightedCells に格納 → recolorAll →
    ```
    
    ---
    
    図2：クライアント内データ変換フロー
    
    APIで受け取ったデータが、最終的に地図の色・ポップアップ・凡例へ変換される経路です。
    
    mermaid
    
    ```mermaid
    %%{init: {'theme': 'neutral', 'themeVariables': {'edgeColor': '#333333', 'lineColor': '#333333','bodyBkg': '#ffffff', 'mainBkg': '#ffffff'}}}%%
    flowchart TD
    
    subgraph API_RES["API レスポンス"]
        R1["data[]\n{grid_key, bounds, ap_cnt, ssix_security_rank,\navg_rssi, p_interf, worst_pair,...}"]
        R2["cells[] モード1\n{grid_key, avg_rssi, max_security_rank}"]
        R3["cells[] モード2\n{grid_key, match_count,\nany_bssid_cnt, all_bssid_cnt}"]
        R4["counts{}\n{ap:[], ssid:[], standard:[]}"]
    end
    
    subgraph STORE["グローバル変数（クライアント内ストア）"]
        S1["gridState\nMap&lt;grid_key, rect_data&gt;"]
        S2["highlightedCells\nMap&lt;grid_key, ssid_data&gt;"]
        S4["globalLegendCounts {}"]
    end
    
    subgraph COLOR["色計算（colorMode + データ値 → hex）"]
        C1["getColor(data)\n通常グリッド色"]
        C2["apColor / ssidColor"]
        C3["standardColor / securityColor"]
        C4["securityRatioColor"]
        C5["ssidApCountColor / rssiColor\nSSID解析モード1"]
        C6["comboColor\nSSID解析モード2"]
    end
    
    subgraph OUTPUT["出力（地図 UI）"]
        O1["L.rectangle\nfillColor / fillOpacity\n→ 地図上の矩形"]
        O2["Popup HTML\n→ クリック時の吹き出し"]
        O3["#legend\n→ 凡例（色＋メッシュ数）"]
    end
    
    R1 --> S1
    R2 --> S2
    R3 --> S2
    R4 --> S4
    
    S1 -->|"data を渡す"| C1
    C1 --> C2
    C1 --> C3
    C1 --> C4
    
    S2 -->|"ssid_ap_cnt / avg_rssi\nmax_standard_cnt"| C5
    S2 -->|"match_count"| C6
    
    C2 -->|hex| O1
    C3 -->|hex| O1
    C4 -->|hex| O1
    C5 -->|hex| O1
    C6 -->|hex| O1
    
    S1 -->|"data を makePopupContent へ"| O2
    S2 -->|"ssid_data を makePopupContent へ"| O2
    
    S4 -->|"computeLegendCounts 経由"| O3
    S1 -->|"S4 未取得時のフォールバック"| O3
    ```
    
    ---
