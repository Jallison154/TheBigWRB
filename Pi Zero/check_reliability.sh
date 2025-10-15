#!/bin/bash
# WRB Reliability Status Checker

echo "🛡️  WRB System Reliability Status"
echo "=================================="
echo ""

# Check main service
echo "📊 Main Service (WRB-enhanced.service):"
if systemctl is-active --quiet WRB-enhanced.service; then
    echo "  ✅ Status: RUNNING"
else
    echo "  ❌ Status: NOT RUNNING"
fi

# Check auto-start service
echo ""
echo "🔄 Auto-Start Service (WRB-auto-start.service):"
if systemctl is-active --quiet WRB-auto-start.service; then
    echo "  ✅ Status: ENABLED"
else
    echo "  ❌ Status: DISABLED"
fi

# Check watchdog service
echo ""
echo "🐕 Watchdog Service (WRB-watchdog.service):"
if systemctl is-active --quiet WRB-watchdog.service; then
    echo "  ✅ Status: MONITORING"
else
    echo "  ❌ Status: NOT MONITORING"
fi

# Check if services are enabled for auto-start
echo ""
echo "🚀 Auto-Start Configuration:"
if systemctl is-enabled --quiet WRB-enhanced.service 2>/dev/null; then
    echo "  ✅ WRB-enhanced.service: ENABLED for auto-start"
else
    echo "  ❌ WRB-enhanced.service: NOT ENABLED for auto-start"
fi

if systemctl is-enabled --quiet WRB-auto-start.service 2>/dev/null; then
    echo "  ✅ WRB-auto-start.service: ENABLED for auto-start"
else
    echo "  ❌ WRB-auto-start.service: NOT ENABLED for auto-start"
fi

if systemctl is-enabled --quiet WRB-watchdog.service 2>/dev/null; then
    echo "  ✅ WRB-watchdog.service: ENABLED for auto-start"
else
    echo "  ❌ WRB-watchdog.service: NOT ENABLED for auto-start"
fi

# Show recent watchdog activity
echo ""
echo "📝 Recent Watchdog Activity:"
if [ -f "/var/log/WRB-watchdog.log" ]; then
    echo "  Last 5 watchdog entries:"
    tail -5 /var/log/WRB-watchdog.log | sed 's/^/    /'
else
    echo "  ⚠️  No watchdog log file found"
fi

# Show service restart count
echo ""
echo "🔄 Service Restart Information:"
echo "  Main service restart count: $(systemctl show WRB-enhanced.service --property=ExecMainStatus --value 2>/dev/null || echo 'Unknown')"
echo "  Watchdog restart count: $(systemctl show WRB-watchdog.service --property=ExecMainStatus --value 2>/dev/null || echo 'Unknown')"

# Overall reliability score
echo ""
echo "🎯 RELIABILITY ASSESSMENT:"
running_services=0
enabled_services=0

if systemctl is-active --quiet WRB-enhanced.service; then ((running_services++)); fi
if systemctl is-active --quiet WRB-auto-start.service; then ((running_services++)); fi
if systemctl is-active --quiet WRB-watchdog.service; then ((running_services++)); fi

if systemctl is-enabled --quiet WRB-enhanced.service 2>/dev/null; then ((enabled_services++)); fi
if systemctl is-enabled --quiet WRB-auto-start.service 2>/dev/null; then ((enabled_services++)); fi
if systemctl is-enabled --quiet WRB-watchdog.service 2>/dev/null; then ((enabled_services++)); fi

total_score=$((running_services + enabled_services))
max_score=6

echo "  Running Services: $running_services/3"
echo "  Auto-Start Enabled: $enabled_services/3"
echo "  Reliability Score: $total_score/$max_score"

if [ $total_score -eq $max_score ]; then
    echo "  🏆 EXCELLENT - Maximum reliability achieved!"
elif [ $total_score -ge 4 ]; then
    echo "  ✅ GOOD - High reliability"
elif [ $total_score -ge 2 ]; then
    echo "  ⚠️  FAIR - Some reliability features missing"
else
    echo "  ❌ POOR - Reliability features need attention"
fi

echo ""
echo "🔧 Quick Commands:"
echo "  Restart all services: sudo systemctl restart WRB-enhanced WRB-watchdog"
echo "  View live logs:       sudo journalctl -u WRB-enhanced.service -f"
echo "  View watchdog logs:   sudo tail -f /var/log/WRB-watchdog.log"
echo "  Check service status: sudo systemctl status WRB-enhanced.service"
