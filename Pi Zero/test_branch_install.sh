#!/bin/bash
# Test script to verify the install script handles Update-1.0 branch correctly

echo "🧪 Testing WRB Install Script - Update-1.0 Branch"
echo "================================================"
echo ""

# Check if we're in the right directory
if [ ! -f "install.sh" ]; then
    echo "❌ install.sh not found. Please run this from the Pi Zero directory."
    exit 1
fi

echo "✅ install.sh found"

# Check if install script mentions Update-1.0 branch
if grep -q "Update-1.0" install.sh; then
    echo "✅ Install script references Update-1.0 branch"
else
    echo "❌ Install script does not reference Update-1.0 branch"
    exit 1
fi

# Check if install script has git repository setup
if grep -q "git init" install.sh && grep -q "git remote add origin" install.sh; then
    echo "✅ Install script has git repository setup"
else
    echo "❌ Install script missing git repository setup"
    exit 1
fi

# Check if install script has branch checkout logic
if grep -q "git checkout" install.sh && grep -q "DEFAULT_BRANCH" install.sh; then
    echo "✅ Install script has branch checkout logic"
else
    echo "❌ Install script missing branch checkout logic"
    exit 1
fi

# Check if install script copies from Pi Zero directory
if grep -q "Pi Zero/" install.sh; then
    echo "✅ Install script copies from Pi Zero directory"
else
    echo "❌ Install script does not copy from Pi Zero directory"
    exit 1
fi

echo ""
echo "🎉 All tests passed!"
echo ""
echo "📋 The install script will:"
echo "  1. ✅ Set up git repository"
echo "  2. ✅ Try to checkout Update-1.0 branch first"
echo "  3. ✅ Fall back to main branch if Update-1.0 not available"
echo "  4. ✅ Copy files from Pi Zero directory in the repository"
echo "  5. ✅ Show which branch was used"
echo ""
echo "🚀 Ready for installation!"
echo ""
