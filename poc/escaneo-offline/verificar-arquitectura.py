#!/usr/bin/env python3
"""Chequeo de arquitectura limpia de la prueba de concepto (sección 5.3, RNF-MAN-03).

- Archivos de código de 300 líneas como máximo (sin contar los generados).
- Funciones de 50 líneas como máximo en el código de producción (Dart: conteo
  aproximado por llaves; TypeScript lo revisa ESLint con max-lines-per-function).
  En las pruebas, el main() que agrupa los casos queda exento.
- La capa de dominio no importa paquetes externos (Flutter, Drift, http, NestJS...).

Uso: python3 verificar-arquitectura.py   (sale con código 1 si algo falla)
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).parent
SOURCES = [ROOT / 'app_movil' / 'lib', ROOT / 'app_movil' / 'test', ROOT / 'servidor-prueba' / 'src',
           ROOT / 'servidor-prueba' / 'test']
MAX_FILE, MAX_FUNCTION = 300, 50
DART_FUNCTION = re.compile(r'^\s*(?!if\b|for\b|while\b|switch\b|return\b|else\b|try\b|catch\b)'
                           r'[\w<>?,\s\[\]]*\b\w+\s*\([^;]*\)\s*(async\s*)?\{\s*$')
DOMAIN_FORBIDDEN = re.compile(r"^import\s+'package:|^import .*from '(@nestjs|express|node:|crypto|qrcode)")


def code_files():
    for base in SOURCES:
        for path in base.rglob('*'):
            if path.suffix in ('.dart', '.ts') and not path.name.endswith('.g.dart'):
                yield path


def long_dart_functions(lines):
    for start, line in enumerate(lines):
        if not DART_FUNCTION.match(line):
            continue
        depth = 0
        for end in range(start, len(lines)):
            depth += lines[end].count('{') - lines[end].count('}')
            if depth <= 0:
                break
        if end - start + 1 > MAX_FUNCTION:
            yield start + 1, end - start + 1


def check(path):
    lines = path.read_text(encoding='utf-8').splitlines()
    rel = path.relative_to(ROOT)
    if len(lines) > MAX_FILE:
        yield f'{rel}: {len(lines)} líneas (máximo {MAX_FILE})'
    if path.suffix == '.dart' and '/test/' not in path.as_posix():
        for line_no, size in long_dart_functions(lines):
            yield f'{rel}:{line_no}: función de {size} líneas (máximo {MAX_FUNCTION})'
    if '/domain/' in path.as_posix():
        for i, line in enumerate(lines, 1):
            if DOMAIN_FORBIDDEN.search(line):
                yield f'{rel}:{i}: el dominio no puede importar "{line.strip()}"'


def main():
    problems = [p for path in code_files() for p in check(path)]
    for problem in problems:
        print(problem)
    print(f'{len(problems)} problema(s) de arquitectura.')
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main())
