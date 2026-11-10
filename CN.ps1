        for(j = 0; j < n; j++) {
            scanf("%d", &a[i][j]);
            if(i != j && a[i][j] == 0) a[i][j] = INF;
        }

    printf("Enter source (0 to %d): ", n-1);
    scanf("%d", &s);

    for(i = 0; i < n; i++) d[i] = INF;
    d[s] = 0;

    for(i = 0; i < n; i++) {
        min = INF; u = -1;
        for(j = 0; j < n; j++)
            if(!v[j] && d[j] < min) min = d[j], u = j;

        if(u == -1) break;
        v[u] = 1;

        for(j = 0; j < n; j++)
            if(!v[j] && d[u] + a[u][j] < d[j])
                d[j] = d[u] + a[u][j];
    }

    for(i = 0; i < n; i++)
        printf("Distance to %d = %d\n", i, d[i]);

    return 0;
}
'@
$path = Join-Path $folder '4. Dijkstra Shortest Path Algorithm.c'
Set-Content -LiteralPath $path -Value $content -Encoding UTF8

$content = @'
#include <stdio.h>

int main() {
    int a[50], n, i, j, t;

    printf("Enter number of frames: ");
    scanf("%d", &n);

    printf("Enter frame numbers:\n");
    for(i = 0; i < n; i++) scanf("%d", &a[i]);

    for(i = 0; i < n-1; i++)
        for(j = 0; j < n-i-1; j++)
            if(a[j] > a[j+1]) {
                t = a[j];
                a[j] = a[j+1];
                a[j+1] = t;
            }

    printf("Sorted frames:\n");
    for(i = 0; i < n; i++) printf("%d ", a[i]);

    return 0;
}
'@
$path = Join-Path $folder '9. Frame Sorting in Buffers.c'
Set-Content -LiteralPath $path -Value $content -Encoding UTF8

$content = @'
#include <stdio.h>
#include <string.h>

void crc(char data[], char poly[]) {
    char temp[200];
    int i, j, n = strlen(data), m = strlen(poly);

    strcpy(temp, data);
    for(i = 0; i < m - 1; i++) strcat(temp, "0");

    for(i = 0; i < n; i++)
        if(temp[i] == '1')
            for(j = 0; j < m; j++)
                temp[i+j] = (temp[i+j] == poly[j]) ? '0' : '1';

    printf("CRC: ");
    for(i = n; i < n + m - 1; i++) printf("%c", temp[i]);
    printf("\n");
}

int main() {
    char d[100];

    printf("Enter binary data: ");
    scanf("%99s", d);

    crc(d, "1100000001111");       // CRC-12
    crc(d, "11000000000000101");   // CRC-16
    crc(d, "10001000000100001");   // CRC-CCITT
    return 0;
}
'@
$path = Join-Path $folder '2. CRC-12 CRC-16 CRC-CCITT.c'
Set-Content -LiteralPath $path -Value $content -Encoding UTF8

Write-Host "Created $($folder) with all lab files." -ForegroundColor Green
Write-Host 'Files created:'
Get-ChildItem -LiteralPath $folder | Select-Object -ExpandProperty Name
