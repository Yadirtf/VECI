#!/usr/bin/env python3
"""Arquitectura limpia de la app Flutter (sección 5.3.4, RNF-MAN-03 y HU-01-10).

Falla (código 1) si:
- un archivo de lib/ o test/ pasa de 300 líneas (los *.g.dart generados no cuentan);
- una función o método de lib/ pasa de 50 líneas (conteo por llaves);
- domain/ importa un paquete (Flutter, Drift, http...) o un archivo fuera de su dominio;
- data/ importa presentation/, o presentation/ importa data/;
- una funcionalidad importa archivos de otra (solo core/di y core/router las conectan);
- core/ importa funcionalidades (salvo core/di y core/router, que son la composición).

Uso: python3 tools/arquitectura/verificar-flutter.py apps/mobile
"""
import pathlib
import re
import sys

MAX_ARCHIVO, MAX_FUNCION = 300, 50
FUNCION = re.compile(r'^\s*(?!if\b|for\b|while\b|switch\b|return\b|else\b|try\b|catch\b|do\b)'
                     r'[\w<>?,\s\[\]]*\b\w+\s*\([^;]*\)\s*(async\s*)?\{\s*$')
IMPORTACION = re.compile(r"^\s*(?:import|export)\s+'([^']+)'")
COMPOSICION = ('core/di/', 'core/router/')


def archivos(raiz):
    for carpeta in ('lib', 'test'):
        for ruta in sorted((raiz / carpeta).rglob('*.dart')):
            if not ruta.name.endswith('.g.dart'):
                yield ruta


def funciones_largas(lineas):
    for inicio, linea in enumerate(lineas):
        if not FUNCION.match(linea):
            continue
        profundidad, fin = 0, inicio
        for fin in range(inicio, len(lineas)):
            profundidad += lineas[fin].count('{') - lineas[fin].count('}')
            if profundidad <= 0:
                break
        if fin - inicio + 1 > MAX_FUNCION:
            yield inicio + 1, fin - inicio + 1


def destino(ruta, objetivo, lib):
    """Ruta relativa a lib/ de una importación, o None si es un paquete externo."""
    if objetivo.startswith('package:veci/'):
        return objetivo[len('package:veci/'):]
    if objetivo.startswith(('package:', 'dart:')):
        return None
    return (ruta.parent / objetivo).resolve().relative_to(lib.resolve()).as_posix()


def capa(rel):
    partes = rel.split('/')
    if partes[0] == 'features' and len(partes) > 2:
        return partes[1], partes[2]
    return None, None


def problemas_de_importacion(rel, objetivo, destino_rel):
    funcionalidad, capa_origen = capa(rel)
    if capa_origen == 'domain':
        if destino_rel is None and not objetivo.startswith('dart:'):
            return f'el dominio no puede importar el paquete "{objetivo}"'
        if destino_rel and not destino_rel.startswith(f'features/{funcionalidad}/domain/'):
            return f'el dominio solo importa su dominio, no "{objetivo}"'
    if destino_rel is None:
        return None
    destino_funcionalidad, capa_destino = capa(destino_rel)
    if funcionalidad and destino_funcionalidad and funcionalidad != destino_funcionalidad:
        return f'una funcionalidad no importa archivos de otra: "{objetivo}"'
    if (capa_origen, capa_destino) in (('data', 'presentation'), ('presentation', 'data')):
        return f'{capa_origen}/ no puede importar {capa_destino}/: "{objetivo}"'
    if rel.startswith('core/') and not rel.startswith(COMPOSICION) and destino_funcionalidad:
        return f'core/ no conoce funcionalidades: "{objetivo}"'
    return None


def revisar(ruta, raiz):
    lineas = ruta.read_text(encoding='utf-8').splitlines()
    nombre = ruta.relative_to(raiz).as_posix()
    if len(lineas) > MAX_ARCHIVO:
        yield f'{nombre}: {len(lineas)} líneas (máximo {MAX_ARCHIVO})'
    if '/test/' in f'/{nombre}':
        return
    for numero, tamano in funciones_largas(lineas):
        yield f'{nombre}:{numero}: función de {tamano} líneas (máximo {MAX_FUNCION})'
    lib = raiz / 'lib'
    rel = ruta.relative_to(lib).as_posix()
    for numero, linea in enumerate(lineas, 1):
        coincidencia = IMPORTACION.match(linea)
        if coincidencia:
            objetivo = coincidencia.group(1)
            problema = problemas_de_importacion(rel, objetivo, destino(ruta, objetivo, lib))
            if problema:
                yield f'{nombre}:{numero}: {problema}'


def main():
    raiz = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else 'apps/mobile')
    problemas = [p for ruta in archivos(raiz) for p in revisar(ruta, raiz)]
    for problema in problemas:
        print(problema)
    print(f'{len(problemas)} problema(s) de arquitectura en {raiz}.')
    return 1 if problemas else 0


if __name__ == '__main__':
    sys.exit(main())
