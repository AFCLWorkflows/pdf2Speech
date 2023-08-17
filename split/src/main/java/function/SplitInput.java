package function;

import lombok.*;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class SplitInput {
    private String inputFile;
    private String inputBucket;
    private String outputBucket;
}
