#!/bin/bash
# Development script for Viernes Mobile

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Help function
show_help() {
    echo "🚀 Viernes Mobile Development Helper"
    echo ""
    echo "Usage: ./scripts/dev.sh [command]"
    echo ""
    echo "Commands:"
    echo "  setup           - Setup project dependencies"
    echo "  dev [device]    - Run in development mode"
    echo "  prod [device]   - Run in production mode"
    echo "  devices         - List available devices"
    echo "  build-dev       - Build development APK"
    echo "  build-prod      - Build production APK"
    echo "  clean           - Clean project"
    echo "  test            - Run tests"
    echo "  analyze         - Analyze code"
    echo "  generate        - Generate code with build_runner"
    echo "  doctor          - Run flutter doctor"
    echo "  help            - Show this help"
    echo ""
    echo "Examples:"
    echo "  ./scripts/dev.sh setup"
    echo "  ./scripts/dev.sh dev"
    echo "  ./scripts/dev.sh dev chrome"
    echo "  ./scripts/dev.sh dev FB419AB3-DB53-4860-A812-F619AEE5D222"
    echo "  ./scripts/dev.sh devices"
    echo "  ./scripts/dev.sh build-prod"
}

# Setup function
setup_project() {
    print_step "Setting up Viernes Mobile project..."

    print_step "Running flutter doctor..."
    flutter doctor

    print_step "Getting Flutter dependencies..."
    flutter pub get

    print_step "Generating code..."
    flutter packages pub run build_runner build

    print_success "Project setup complete!"
}

# Development mode
run_dev() {
    print_step "Running Viernes Mobile in DEVELOPMENT mode..."

    # Check for specific device argument
    if [ "$2" != "" ]; then
        print_step "Running on device: $2"
        flutter run --flavor=dev --dart-define=ENVIRONMENT=dev -t lib/main_dev.dart -d "$2"
    else
        flutter run --flavor=dev --dart-define=ENVIRONMENT=dev -t lib/main_dev.dart
    fi
}

# Production mode
run_prod() {
    print_step "Running Viernes Mobile in PRODUCTION mode..."

    # Check for specific device argument
    if [ "$2" != "" ]; then
        print_step "Running on device: $2"
        flutter run --flavor=prod --dart-define=ENVIRONMENT=production -t lib/main_prod.dart -d "$2"
    else
        flutter run --flavor=prod --dart-define=ENVIRONMENT=production -t lib/main_prod.dart
    fi
}

# List devices
list_devices() {
    print_step "Available devices:"
    flutter devices
    echo ""
    print_step "To run on specific device use:"
    echo "  ./scripts/dev.sh dev <device-id>"
    echo "  ./scripts/dev.sh prod <device-id>"
}

# Build development APK
build_dev() {
    print_step "Building development APK..."
    flutter build apk --flavor=dev --dart-define=ENVIRONMENT=dev -t lib/main_dev.dart
    print_success "Development APK built successfully!"
    echo "Location: build/app/outputs/flutter-apk/app-dev-release.apk"
}

# Build production APK
build_prod() {
    print_step "Building production APK..."
    flutter build apk --flavor=prod --dart-define=ENVIRONMENT=production -t lib/main_prod.dart
    print_success "Production APK built successfully!"
    echo "Location: build/app/outputs/flutter-apk/app-prod-release.apk"
}

# Clean project
clean_project() {
    print_step "Cleaning project..."
    flutter clean
    print_success "Project cleaned!"
}

# Run tests
run_tests() {
    print_step "Running tests..."
    flutter test
}

# Analyze code
analyze_code() {
    print_step "Analyzing code..."
    flutter analyze
}

# Generate code
generate_code() {
    print_step "Generating code with build_runner..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    print_success "Code generation complete!"
}

# Flutter doctor
run_doctor() {
    print_step "Running Flutter doctor..."
    flutter doctor -v
}

# Main script logic
case "${1}" in
    setup)
        setup_project
        ;;
    dev)
        run_dev "$@"
        ;;
    prod)
        run_prod "$@"
        ;;
    devices)
        list_devices
        ;;
    build-dev)
        build_dev
        ;;
    build-prod)
        build_prod
        ;;
    clean)
        clean_project
        ;;
    test)
        run_tests
        ;;
    analyze)
        analyze_code
        ;;
    generate)
        generate_code
        ;;
    doctor)
        run_doctor
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: ${1}"
        echo ""
        show_help
        exit 1
        ;;
esac