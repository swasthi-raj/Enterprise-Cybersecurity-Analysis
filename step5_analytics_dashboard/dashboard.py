"""
SOC Database Analytics Dashboard
MIS686 Term Project - Step 5
Enterprise Cybersecurity Incident & Threat Intelligence

This script connects to your AWS RDS database, executes analytical queries,
and creates comprehensive visualizations for cybersecurity analytics.
"""

import mysql.connector
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px
import numpy as np
from config import DB_CONFIG
import os

# Set visualization styles
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (14, 8)
px.defaults.template = "plotly_white"

# Ensure charts directory exists
os.makedirs('step5_analytics_dashboard/charts', exist_ok=True)

def connect_to_database():
    """Establish connection to the AWS RDS database"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        print("✓ Successfully connected to AWS RDS (soc_db)")
        return connection
    except Exception as e:
        print(f"✗ Error connecting to database: {e}")
        return None


def run_query(connection, query, query_name=""):
    """Execute SQL query and return results as pandas DataFrame"""
    try:
        if query_name:
            print(f"  Executing: {query_name}")
        df = pd.read_sql(query, connection)
        return df
    except Exception as e:
        print(f"✗ Error executing query {query_name}: {e}")
        return None


def analytical_query_1(connection):
    """
    Q1: MITRE ATT&CK tactics and techniques with most high/critical alerts
    Creates: Bar chart showing alerts by MITRE tactic
    """
    query = """
    SELECT
        dr.tactic,
        dr.technique,
        COUNT(*) AS alert_count
    FROM alerts AS a
    JOIN detection_rules AS dr
        ON a.rule_id = dr.rule_id
    WHERE a.severity IN ('high', 'critical')
    GROUP BY dr.tactic, dr.technique
    ORDER BY alert_count DESC;
    """
    
    df = run_query(connection, query, "Q1 - MITRE ATT&CK High/Critical Alerts")
    
    if df is not None and not df.empty:
        # Aggregate by tactic for clearer visualization
        df_tactic = df.groupby("tactic")["alert_count"].sum().reset_index()
        
        # Create bar chart
        fig = px.bar(
            df_tactic,
            x="tactic",
            y="alert_count",
            color="tactic",
            title="Q1: High/Critical Alerts by MITRE ATT&CK Tactic",
            text="alert_count",
            labels={"tactic": "MITRE Tactic", "alert_count": "Alert Count"}
        )
        
        fig.update_layout(
            font=dict(size=14),
            title_font=dict(size=18),
            showlegend=False,
            height=600
        )
        
        fig.update_traces(textposition="outside")
        fig.write_image('step5_analytics_dashboard/charts/Q1_pie_alerts_by_tactic.png', width=1400, height=800)
        
        # Also create technique-level chart
        df_top_techniques = df.nlargest(15, "alert_count")
        fig2 = px.bar(
            df_top_techniques,
            x="technique",
            y="alert_count",
            color="tactic",
            title="Q1: Top 15 MITRE Techniques by High/Critical Alerts",
            labels={"technique": "MITRE Technique", "alert_count": "Alert Count"}
        )
        fig2.update_layout(xaxis_tickangle=-45, height=600)
        fig2.write_image('step5_analytics_dashboard/charts/Q1_simple_chart_by_tactic.png', width=1400, height=800)
        
        print(f"  ✓ Generated Q1 charts (Tactics: {len(df_tactic)} | Techniques: {len(df)})")
        
    return df


def analytical_query_2(connection):
    """
    Q2: Assets generating highest alerts normalized by criticality
    Creates: Bar chart and scatter plot of asset risk
    """
    query = """
    SELECT
        a.asset_id,
        a.hostname,
        a.asset_type,
        a.criticality,
        COUNT(al.alert_id) AS total_alerts,
        CASE
            WHEN a.criticality = 'low' THEN COUNT(al.alert_id) * 1
            WHEN a.criticality = 'medium' THEN COUNT(al.alert_id) * 2
            WHEN a.criticality = 'high' THEN COUNT(al.alert_id) * 3
            WHEN a.criticality = 'critical' THEN COUNT(al.alert_id) * 4
        END AS normalized_alert_score
    FROM assets a
    LEFT JOIN network_logs nl
        ON nl.asset_id = a.asset_id
    LEFT JOIN alerts al
        ON al.log_id = nl.log_id
    GROUP BY
        a.asset_id, a.hostname, a.asset_type, a.criticality
    ORDER BY
        normalized_alert_score DESC;
    """
    
    df = run_query(connection, query, "Q2 - Asset Risk by Normalized Alert Score")
    
    if df is not None and not df.empty:
        top_assets = df.nlargest(10, "normalized_alert_score")
        
        # Bar chart
        fig = px.bar(
            top_assets.sort_values("normalized_alert_score"),
            x="normalized_alert_score",
            y="hostname",
            color="asset_type",
            text="normalized_alert_score",
            orientation='h',
            title="Q2: Top 10 Risky Assets (Normalized by Criticality)",
            labels={"normalized_alert_score": "Normalized Alert Score", "hostname": "Asset Hostname"},
            hover_data=["asset_id", "criticality", "total_alerts"]
        )
        
        fig.update_layout(height=600, font=dict(size=14))
        fig.update_traces(textposition="outside")
        fig.write_image('step5_analytics_dashboard/charts/Q2_top_assets_normalized_alert_score.png', width=1400, height=800)
        
        # Scatter plot: Criticality vs Alert Score
        fig2 = px.scatter(
            df,
            x="total_alerts",
            y="normalized_alert_score",
            color="criticality",
            size="normalized_alert_score",
            hover_data=["hostname", "asset_type"],
            title="Q2: Asset Criticality vs Alert Score (Scatter)",
            labels={"total_alerts": "Total Alerts", "normalized_alert_score": "Normalized Score"}
        )
        fig2.write_image('step5_analytics_dashboard/charts/Q2_scatter_criticality_vs_alert_score.png', width=1400, height=800)
        
        # Bar chart by asset type
        df_by_type = df.groupby("asset_type")["normalized_alert_score"].mean().reset_index()
        fig3 = px.bar(
            df_by_type,
            x="asset_type",
            y="normalized_alert_score",
            title="Q2: Average Normalized Alert Score by Asset Type",
            color="asset_type"
        )
        fig3.write_image('step5_analytics_dashboard/charts/Q2_normalized_score_by_asset_type.png', width=1400, height=800)
        
        print(f"  ✓ Generated Q2 charts (Total Assets: {len(df)} | Top 10 shown)")
        
    return df


def analytical_query_3(connection):
    """
    Q3: Detection rules with highest false-positive rate
    Creates: Bar chart and comparison visualizations
    """
    query = """
    SELECT
        dr.rule_id,
        dr.name AS detection_rule,
        dr.tactic,
        dr.technique,
        COUNT(a.alert_id) AS total_alerts,
        SUM(a.status = 'false_positive') AS false_positives,
        SUM(a.status IN ('open','in_progress','contained','resolved')) AS real_alerts,
        ROUND(
            SUM(a.status = 'false_positive') / COUNT(a.alert_id),
            3
        ) AS false_positive_rate
    FROM detection_rules dr
    LEFT JOIN alerts a
        ON a.rule_id = dr.rule_id
    GROUP BY
        dr.rule_id, dr.name, dr.tactic, dr.technique
    HAVING COUNT(a.alert_id) > 0
    ORDER BY
        false_positive_rate DESC;
    """
    
    df = run_query(connection, query, "Q3 - Detection Rule False Positive Analysis")
    
    if df is not None and not df.empty:
        top_rules = df.nlargest(10, "false_positive_rate")
        
        # Bar chart of FP rate
        fig = px.bar(
            top_rules,
            x="detection_rule",
            y="false_positive_rate",
            color="tactic",
            title="Q3: Detection Rules with Highest False-Positive Rate (Top 10)",
            labels={"detection_rule": "Detection Rule", "false_positive_rate": "False Positive Rate"},
            hover_data=["rule_id", "technique", "total_alerts", "false_positives"]
        )
        
        fig.update_layout(xaxis_tickangle=-45, height=600, font=dict(size=14))
        fig.write_image('step5_analytics_dashboard/charts/Q3_false_positive_rate_top10.png', width=1400, height=800)
        
        # Average FP rate by tactic
        df_by_tactic = df.groupby("tactic")["false_positive_rate"].mean().reset_index()
        fig2 = px.bar(
            df_by_tactic,
            x="tactic",
            y="false_positive_rate",
            title="Q3: Average False Positive Rate by MITRE Tactic",
            color="tactic"
        )
        fig2.write_image('step5_analytics_dashboard/charts/Q3_avg_fp_rate_by_tactic.png', width=1400, height=800)
        
        # False vs Real alerts comparison
        fig3 = px.scatter(
            df,
            x="total_alerts",
            y="false_positive_rate",
            size="false_positives",
            color="tactic",
            hover_data=["detection_rule", "technique"],
            title="Q3: Alert Volume vs False Positive Rate (Scatter)",
            labels={"total_alerts": "Total Alerts", "false_positive_rate": "FP Rate"}
        )
        fig3.write_image('step5_analytics_dashboard/charts/Q3_scatter_alerts_vs_fp_rate.png', width=1400, height=800)
        
        # Stacked comparison
        top_rules_compare = top_rules.copy()
        fig4 = px.bar(
            top_rules_compare,
            x="detection_rule",
            y=["false_positives", "real_alerts"],
            title="Q3: False Positives vs Real Alerts (Top 10 Rules)",
            labels={"value": "Count", "detection_rule": "Detection Rule"}
        )
        fig4.update_layout(xaxis_tickangle=-45)
        fig4.write_image('step5_analytics_dashboard/charts/Q3_false_vs_real_alerts.png', width=1400, height=800)
        
        print(f"  ✓ Generated Q3 charts (Total Rules: {len(df)} | Top 10 shown)")
        
    return df


def analytical_query_5(connection):
    """
    Q5: Mean Time To Detect/Contain/Resolve by severity
    Creates: Grouped bar chart of incident response timing metrics
    """
    query = """
    SELECT
        severity,
        ROUND(AVG(TIMESTAMPDIFF(HOUR, detected_at, opened_at)), 2) AS mttd_hours,
        ROUND(AVG(TIMESTAMPDIFF(HOUR, detected_at, contained_at)), 2) AS mttc_hours,
        ROUND(AVG(TIMESTAMPDIFF(HOUR, opened_at, closed_at)), 2) AS mttr_hours
    FROM incidents
    WHERE
        detected_at IS NOT NULL
        AND opened_at IS NOT NULL
        AND contained_at IS NOT NULL
        AND closed_at IS NOT NULL
    GROUP BY severity
    ORDER BY FIELD(severity, 'low', 'medium', 'high', 'critical');
    """
    
    df = run_query(connection, query, "Q5 - MTTD/MTTC/MTTR by Severity")
    
    if df is not None and not df.empty:
        # Melt for grouped bar chart
        df_melt = df.melt(
            id_vars="severity",
            value_vars=["mttd_hours", "mttc_hours", "mttr_hours"],
            var_name="metric",
            value_name="hours"
        )
        
        # Grouped bar chart
        fig = px.bar(
            df_melt,
            x="severity",
            y="hours",
            color="metric",
            barmode="group",
            title="Q5: Incident Response Timing - MTTD / MTTC / MTTR by Severity",
            labels={"severity": "Severity Level", "hours": "Hours", "metric": "Metric"},
            category_orders={"severity": ["low", "medium", "high", "critical"]}
        )
        
        fig.update_layout(height=600, font=dict(size=14))
        fig.write_image('step5_analytics_dashboard/charts/Q5_mttd_mttc_mttr_by_severity.png', width=1400, height=800)
        
        # Individual metric charts
        for metric in ["mttd_hours", "mttc_hours", "mttr_hours"]:
            metric_name = metric.replace("_hours", "").upper()
            fig_single = px.bar(
                df,
                x="severity",
                y=metric,
                title=f"Q5: {metric_name} by Severity",
                color="severity",
                text=metric
            )
            fig_single.update_traces(textposition="outside")
            fig_single.write_image(f'step5_analytics_dashboard/charts/Q5_{metric.replace("_hours", "")}_by_severity.png', width=1400, height=800)
        
        print(f"  ✓ Generated Q5 charts (MTTD, MTTC, MTTR by severity)")
        
    return df


def create_dashboard():
    """Main function to create the complete SOC analytics dashboard"""
    print("=" * 70)
    print("SOC DATABASE ANALYTICS DASHBOARD")
    print("Enterprise Cybersecurity Incident & Threat Intelligence")
    print("=" * 70)
    
    # Connect to database
    connection = connect_to_database()
    
    if connection is None:
        print("Failed to connect to database. Exiting...")
        return
    
    try:
        # Execute all analytical queries
        print("\n📊 Executing Analytical Queries & Generating Visualizations...\n")
        
        print("Query 1: MITRE ATT&CK High/Critical Alerts")
        df1 = analytical_query_1(connection)
        
        print("\nQuery 2: Asset Risk Analysis")
        df2 = analytical_query_2(connection)
        
        print("\nQuery 3: Detection Rule False Positive Analysis")
        df3 = analytical_query_3(connection)
        
        print("\nQuery 5: Incident Response Timing (MTTD/MTTC/MTTR)")
        df5 = analytical_query_5(connection)
        
        print("\n" + "=" * 70)
        print("✓ Dashboard created successfully!")
        print("=" * 70)
        print(f"\n📁 Charts saved in: step5_analytics_dashboard/charts/")
        print("\nGenerated Visualizations:")
        print("  • Q1: MITRE ATT&CK tactic and technique alerts")
        print("  • Q2: Asset risk by normalized alert score")
        print("  • Q3: Detection rule false positive analysis")
        print("  • Q5: Incident response timing metrics (MTTD/MTTC/MTTR)")
        print("\n" + "=" * 70)
        
    except Exception as e:
        print(f"✗ Error creating dashboard: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        # Close database connection
        if connection:
            connection.close()
            print("\n✓ Database connection closed")


if __name__ == "__main__":
    create_dashboard()
